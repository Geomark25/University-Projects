import math

class Engine:
    def __init__(self, idle_rpm=800, limit_rpm=8000, inertia=0.2, max_torque=185):
        self.rpm = 0.0
        self.running = False
        
        self.inertia = inertia
        self.idle_rpm = idle_rpm
        self.limit_rpm = limit_rpm
        self.max_torque = max_torque
        
        # Low internal friction for a modern 4-cylinder (prevents struggling in 3rd gear)
        self.friction_coeff = 0.006 
        
        # The physical state of the idle air valve (Low-Pass Filter state)
        self.idle_valve = 0.0 

    def get_torque_curve(self, rpm):
        if rpm <= 0: return 0
        
        # Idle torque baseline
        if rpm <= 800: return self.max_torque * 0.7 
        
        # Parabolic torque curve peaking at 4400 RPM
        peak_rpm = 4400.0
        
        # a = -2.6e-8 creates a broad, flat power band typical of modern 4-cylinders
        factor = -2.6e-8 * (rpm - peak_rpm)**2 + 1.0
        
        return max(0, self.max_torque * factor)

    def update(self, dt, throttle, load_torque, ignition_active):
        # --- 1. Ignition ---
        if not self.running:
            if ignition_active:
                self.running = True
                self.rpm = self.idle_rpm 
                self.idle_valve = 0.05 # Initial valve opening
            else:
                self.rpm = max(0, self.rpm - 150 * dt)
            return 0.0

        # --- 2. Jitter-Free Idle Governor ---
        # Calculate theoretical throttle needed
        if self.rpm < self.idle_rpm:
            error = self.idle_rpm - self.rpm
            raw_idle = error * 0.003
        else:
            raw_idle = 0.0
            
        # Cap the computer's maximum rescue throttle to 12% (0.12).
        # This ensures the car stalls if the clutch is dumped or on a hill without gas.
        raw_idle = max(0.0, min(0.12, raw_idle)) 
        
        # Low-Pass Filter (Anti-Jitter)
        # Smoothly slide the physical valve towards the target raw_idle
        self.idle_valve += (raw_idle - self.idle_valve) * 15.0 * dt
        
        # Engine takes whichever is higher: the driver's foot or the idle valve
        effective_throttle = max(throttle, self.idle_valve)

        # --- 3. Physics ---
        # --- 3. Physics ---
        combustion_torque = self.get_torque_curve(self.rpm) * effective_throttle
        
        # Base mechanical friction
        base_friction = 12 + (self.rpm * self.friction_coeff)
        
        # PUMPING LOSSES: The vacuum drag created when the throttle is closed.
        # If throttle is 0.0, this adds massive drag. If throttle is 1.0 (WOT), it adds nothing.
        # PUMPING LOSSES: The vacuum drag created when the throttle is closed.
        # We subtract idle_rpm so it doesn't choke the engine to death at idle.
        revs_above_idle = max(0, self.rpm - self.idle_rpm)
        pumping_loss = (1.0 - effective_throttle) * (revs_above_idle * 0.015)
        
        friction_torque = base_friction + pumping_loss
        
        net_torque = combustion_torque - friction_torque - load_torque
        
        net_torque = combustion_torque - friction_torque - load_torque
        
        # Angular Acceleration
        alpha = net_torque / self.inertia
        self.rpm += alpha * dt * 9.55 
        
        # Limits & Stalling
        self.rpm = min(self.limit_rpm, self.rpm)
        if self.rpm < 200: 
            self.running = False
            self.rpm = 0
            self.idle_valve = 0.0

        return combustion_torque