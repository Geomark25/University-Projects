import math
from .pid import PIDController
from .modes import MODES

class AutoDriverFSM:
    def __init__(self, mode_name="NORMAL"):
        self.state = "STARTUP"
        self.target_speed_kmh = 0.0
        
        # Actuator states
        self.clutch = 1.0
        self.throttle = 0.0
        self.brake = 1.0
        self.ignition = False
        
        # Load Mode Profile
        self.mode = MODES[mode_name]
        self.speed_pid = PIDController(kp=self.mode.pid_kp, ki=self.mode.pid_ki, kd=0.03, integral_limit=1.0)
        self.rpm_pid = PIDController(kp=3.5, ki=2.0, kd=0.1)
        
        self.CREEP_THRESHOLD = 12.0
        self.last_shift_time = 0.0 
        # Engine Braking Memory
        self.is_eb_active = False
        self.eb_base_gear = 0

    def set_mode(self, mode_name):
        """Dynamically switch driving modes on the fly."""
        self.mode = MODES[mode_name]
        self.speed_pid.kp = self.mode.pid_kp
        self.speed_pid.ki = self.mode.pid_ki
        print(f"Agent switched to {self.mode.name} mode.")

    def _get_target_rpm(self, car, gear):
        """Calculates exact engine RPM needed for a specific gear at the current wheel speed."""
        if gear == 0:
            return 800.0 # Idle
            
        gear_ratio = car.gearbox.gears[gear] * car.gearbox.final_drive
        wheel_rpm = (car.velocity / (2 * math.pi * car.wheel_radius)) * 60
        return wheel_rpm * gear_ratio

    def _evaluate_shift_logic(self, car, time_elapsed):
        """Strict Objective-Scoring Scheduler with Stable Downhill Logic"""
        current_rpm = car.engine.rpm
        current_gear = car.gearbox.current_gear
        
        # 1. Hysteresis Cooldown to ensure physical stability
        if time_elapsed - self.last_shift_time < 1.5: 
            return None

        # 2. Ultimate Mechanical Limits
        if current_rpm > 7800 and current_gear < 6:
            return "UPSHIFT"
        if current_rpm < 1200 and current_gear > 1:
            return "DOWNSHIFT"

        # 3. Calculate Required Physics
        speed_error = self.target_speed_kmh - (car.velocity * 3.6)
        
        if speed_error > 0:
            desired_accel = min(self.mode.max_accel, speed_error * self.mode.accel_rate)
        else:
            desired_accel = 0.0

        slope_rad = math.radians(car.slope_angle)
        force_gravity = car.mass * 9.81 * math.sin(slope_rad)
        force_drag = 0.5 * 1.225 * car.frontal_area * car.drag_coeff * car.velocity * abs(car.velocity)
        
        required_wheel_force = force_gravity + force_drag + (car.mass * desired_accel)
        
        # PURE PHYSICS: If the net force required to maintain speed is negative, we need braking.
        needs_braking = required_wheel_force < 0 

        best_gear = current_gear
        best_score = -float('inf')

        for gear in range(1, 7):
            rpm = self._get_target_rpm(car, gear)
            
            if rpm < 1400 or rpm > 7500: 
                continue

            if needs_braking:
                # DOWNHILL ENGINE BRAKING: Cap the RPM to the mode's comfort zone
                if rpm > self.mode.max_eb_rpm: 
                    continue
                score = rpm 
            else:
                ratio = car.gearbox.gears[gear] * car.gearbox.final_drive
                max_torque = car.engine.get_torque_curve(rpm)
                
                # HONEST MATH: Factor in the mode's throttle cap to the available force
                actual_max_torque = max_torque * self.mode.max_throttle
                available_force = (actual_max_torque * ratio) / car.wheel_radius 
                
                safety_margin = 1.0 if gear == current_gear else 1.15
                if available_force < (required_wheel_force * safety_margin):
                    continue 

                # DRIVING MODE PHILOSOPHY
                if self.mode.target_rpm == "MIN":
                    score = -rpm 
                else:
                    score = -abs(rpm - self.mode.target_rpm) 
            
            # ANTI-OSCILLATION PENALTY
            if gear != current_gear:
                score -= 600

            if score > best_score:
                best_score = score
                best_gear = gear

        # Fallback for extreme situations
        if best_score == -float('inf') and not needs_braking:
            best_force = -1
            for gear in range(1, 7):
                rpm = self._get_target_rpm(car, gear)
                if rpm > 7500: continue
                force = (car.engine.get_torque_curve(rpm) * car.gearbox.gears[gear] * car.gearbox.final_drive) / car.wheel_radius
                if force > best_force:
                    best_force = force
                    best_gear = gear

        if best_gear > current_gear:
            return "UPSHIFT"
        elif best_gear < current_gear:
            return "DOWNSHIFT"

        return None

    def update(self, car, target_speed_kmh, dt, time_elapsed):
        self.target_speed_kmh = target_speed_kmh
        current_speed_kmh = car.velocity * 3.6
        normalized_rpm = car.engine.rpm / 8000.0

        # Run the shift logic check if we are in a stable driving state
        shift_command = None
        if self.state == "DRIVING":
            shift_command = self._evaluate_shift_logic(car, time_elapsed)

        if shift_command == "UPSHIFT":
            self.state = "UPSHIFT_CLUTCH_IN"
            #self.speed_pid.reset()
            self.last_shift_time = time_elapsed
        elif shift_command == "DOWNSHIFT":
            self.state = "DOWNSHIFT_CLUTCH_IN"
            #self.speed_pid.reset()
            self.last_shift_time = time_elapsed

        # --- FSM LOGIC ---
        if self.state == "STARTUP":
            if time_elapsed >= 2.0:
                self.ignition = True
                if car.engine.running:
                    self.state = "IDLE"
                    
        elif self.state == "IDLE":
            self.throttle = 0.0
            self.clutch = 1.0
            self.brake = 1.0
            if self.target_speed_kmh > 0:
                self.state = "ENGAGE_GEAR"
                
        elif self.state == "ENGAGE_GEAR":
            car.shift_gear(1, self.clutch)
            self.brake = 0.0
            if self.target_speed_kmh <= self.CREEP_THRESHOLD:
                self.state = "CREEPING"
            else:
                self.state = "LAUNCHING"
                
        elif self.state == "CREEPING":
            self.brake = 0.0
            self.rpm_pid.setpoint = 1200.0 / 8000.0
            self.throttle, _, _, _ = self.rpm_pid.update(normalized_rpm, dt)
            
            speed_error = self.target_speed_kmh - current_speed_kmh
            if speed_error > 0.2:
                self.clutch = max(0.4, self.clutch - (dt * 0.15))
            elif speed_error < -0.2:
                self.clutch = min(1.0, self.clutch + (dt * 0.3))
                
            if self.target_speed_kmh == 0:
                self.state = "STOPPING"
            elif self.target_speed_kmh > self.CREEP_THRESHOLD:
                self.state = "LAUNCHING"

        elif self.state == "LAUNCHING":
            self.brake = 0.0
            self.rpm_pid.setpoint = self.mode.launch_rpm / 8000.0
            self.throttle, _, _, _ = self.rpm_pid.update(normalized_rpm, dt)
            
            if car.engine.rpm > (self.mode.launch_rpm - 300):
                clutch_drop_speed = 0.4 + (self.mode.pid_kp * 0.5) 
                self.clutch = max(0.0, self.clutch - (dt * clutch_drop_speed))
                
            if self.clutch == 0.0:
                self.state = "DRIVING"
                
            if 0 < self.target_speed_kmh <= self.CREEP_THRESHOLD:
                self.state = "CREEPING"
            elif self.target_speed_kmh == 0:
                self.state = "STOPPING"
                
        elif self.state == "DRIVING":
            self.clutch = 0.0
            
            self.speed_pid.setpoint = self.target_speed_kmh
            raw_throttle, _, _, _ = self.speed_pid.update(current_speed_kmh, dt)
            
            speed_error = self.target_speed_kmh - current_speed_kmh
            
            # MUTUAL EXCLUSION: Never press gas and brake at the same time
            # Apply brakes only if speed exceeds target by more than 3 km/h
            if speed_error < -3.0:
                self.brake = min(1.0, abs(speed_error) * 0.15)
                self.throttle = 0.0
            else:
                self.brake = 0.0
                self.throttle = max(0.0, raw_throttle)
            
            if 0 < self.target_speed_kmh <= self.CREEP_THRESHOLD:
                self.state = "CREEPING"
            elif self.target_speed_kmh == 0:
                self.state = "STOPPING"

        # --- UPSHIFT LOGIC ---
        elif self.state == "UPSHIFT_CLUTCH_IN":
            self.throttle = 0.0
            self.clutch = min(1.0, self.clutch + (dt * 6.0))
            if self.clutch >= 0.85:
                car.shift_gear(car.gearbox.current_gear + 1, self.clutch)
                self.state = "UPSHIFT_REV_MATCH"

        elif self.state == "UPSHIFT_REV_MATCH":
            self.throttle = 0.0
            self.clutch = 1.0
            target_match_rpm = self._get_target_rpm(car, car.gearbox.current_gear)
            
            if car.engine.rpm <= target_match_rpm + 150:
                self.state = "UPSHIFT_CLUTCH_OUT"

        elif self.state == "UPSHIFT_CLUTCH_OUT":
            target_match_rpm = self._get_target_rpm(car, car.gearbox.current_gear)
            self.rpm_pid.setpoint = target_match_rpm / 8000.0
            self.throttle, _, _, _ = self.rpm_pid.update(normalized_rpm, dt)
            
            self.clutch = max(0.0, self.clutch - (dt * 6.0))
            if self.clutch == 0.0:
                self.state = "DRIVING"

        # --- DOWNSHIFT LOGIC ---
        elif self.state == "DOWNSHIFT_CLUTCH_IN":
            self.clutch = min(1.0, self.clutch + (dt * 6.0))
            if self.clutch >= 0.85:
                car.shift_gear(car.gearbox.current_gear - 1, self.clutch)
                self.state = "DOWNSHIFT_REV_MATCH"

        elif self.state == "DOWNSHIFT_REV_MATCH":
            self.clutch = 1.0
            target_match_rpm = self._get_target_rpm(car, car.gearbox.current_gear)
            
            self.rpm_pid.setpoint = target_match_rpm / 8000.0
            self.throttle, _, _, _ = self.rpm_pid.update(normalized_rpm, dt)
            
            if car.engine.rpm >= target_match_rpm - 150:
                self.state = "DOWNSHIFT_CLUTCH_OUT"

        elif self.state == "DOWNSHIFT_CLUTCH_OUT":
            target_match_rpm = self._get_target_rpm(car, car.gearbox.current_gear)
            self.rpm_pid.setpoint = target_match_rpm / 8000.0
            self.throttle, _, _, _ = self.rpm_pid.update(normalized_rpm, dt)
            
            self.clutch = max(0.0, self.clutch - (dt * 6.0))
            if self.clutch == 0.0:
                self.state = "DRIVING"

        # --- STOPPING LOGIC ---
        elif self.state == "STOPPING":
            self.throttle = 0.0
            self.brake = min(1.0, self.brake + (dt * 1.5)) 
            
            if car.engine.rpm < 1200 or current_speed_kmh < 15:
                self.clutch = min(1.0, self.clutch + (dt * 4.0))
                
            if current_speed_kmh < 0.5 and self.target_speed_kmh == 0:
                self.state = "IDLE"
            elif self.target_speed_kmh > 0:
                if self.target_speed_kmh <= self.CREEP_THRESHOLD:
                    self.state = "CREEPING"
                else:
                    self.state = "LAUNCHING"

        # Apply safety max throttle limits per the active driving mode
        self.throttle = min(self.throttle, self.mode.max_throttle)

        # Automatic Restart on stall
        if not car.engine.running and self.ignition:
            self.throttle, self.brake, self.clutch = 0.0, 1.0, 1.0
            car.shift_gear(0, self.clutch)
            self.state = "IDLE"

        return {
            'throttle': self.throttle,
            'brake': self.brake,
            'clutch': self.clutch,     
            'ignition': self.ignition
        }