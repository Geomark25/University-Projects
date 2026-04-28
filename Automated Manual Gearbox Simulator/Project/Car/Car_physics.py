import math
import collections
from .Engine import Engine
from .Clutch import Clutch
from .Gearbox import Gearbox

class CarPhysics:
    def __init__(self):
        self.engine = Engine()
        self.clutch = Clutch(max_torque_capacity=350, stiffness=15)
        self.gearbox = Gearbox()
        
        # TOYOTA COROLLA CHASSIS SPECS
        self.mass = 1290        
        self.wheel_radius = 0.31 
        self.drag_coeff = 0.30  
        self.frontal_area = 2.2 
        self.brake_strength = 9000 
        
        self.velocity = 0.0
        self.slope_angle = 0.0
        
        # Fuel calculations
        self.instant_fuel_l_s = 0.0
        self.fuel_display_unit = "L/h"
        self.fuel_display_val = 0.0
        self.fuel_history = collections.deque(maxlen=60) 

        # Diagnostics
        self.clutch_slip_rpm = 0.0

    def shift_gear(self, target_gear, clutch_pedal):
        """
        Attempts to change gear. 
        Stalls the engine if the clutch pedal is not sufficiently pressed.
        """
        if target_gear == self.gearbox.current_gear:
            return

        # Require the clutch pedal to be at least 80% depressed to shift into a gear.
        # Shifting into Neutral (0) without the clutch is technically possible in real life, 
        # but we penalize shifting into any drive gear.
        if target_gear != 0 and clutch_pedal < 0.8:
            self.engine.running = False
            
        self.gearbox.current_gear = target_gear

    def update(self, dt, inputs):
        throttle = inputs['throttle']
        brake = inputs['brake']
        clutch_pedal = inputs['clutch']
        ignition_request = inputs['ignition']

        is_in_neutral = (self.gearbox.current_gear == 0)
        effective_ignition = ignition_request and is_in_neutral
        
        # --- Transmission & Clutch Logic ---
        if is_in_neutral:
            clutch_load_torque = 0.0
            self.clutch_slip_rpm = 0.0 
        else:
            total_ratio = self.gearbox.get_total_ratio()
            wheel_rpm = (self.velocity / (2 * math.pi * self.wheel_radius)) * 60
            trans_input_rpm = wheel_rpm * total_ratio
            
            # Calculate physical slippage error
            self.clutch_slip_rpm = abs(self.engine.rpm - trans_input_rpm)
            
            # Anti-Jitter Clutch Lock (Pedal fully released)
            if clutch_pedal < 0.05: 
                self.engine.rpm = trans_input_rpm
                self.clutch_slip_rpm = 0.0 # Hard locked, zero slip
                
                effective_throttle = max(throttle, self.engine.idle_valve)
                combustion = self.engine.get_torque_curve(self.engine.rpm) * effective_throttle
                
                base_friction = 12 + (self.engine.rpm * self.engine.friction_coeff)
                revs_above_idle = max(0, self.engine.rpm - self.engine.idle_rpm)
                pumping_loss = (1.0 - effective_throttle) * (revs_above_idle * 0.015)
                friction = base_friction + pumping_loss
                
                clutch_load_torque = combustion - friction
            else:
                # Pedal partially or fully pressed: calculate torque transfer through sliding friction
                clutch_load_torque = self.clutch.calculate_torque_transfer(self.engine.rpm, trans_input_rpm, clutch_pedal)

        # --- Update Engine ---
        combustion_torque = self.engine.update(dt, throttle, clutch_load_torque, effective_ignition)

        # --- Fuel Consumption & DFCO ---
        if not self.engine.running:
            self.instant_fuel_l_s = 0.0
            raw_display_val = 0.0
        else:
            power_kw = (combustion_torque * self.engine.rpm * math.pi / 30) / 1000.0
            
            # 1. DYNAMIC BSFC CALCULATION (g/kWh)
            # Engines are most efficient around 3000 RPM. Penalize very low or very high revs.
            rpm_factor = abs(self.engine.rpm - 3000) / 4000.0 
            
            # Engines are most efficient at high load (open throttle = no vacuum drag).
            load_factor = 1.0 - min(1.0, throttle / 0.8)
            # Add fuel enrichment penalty if flooring it past 80%
            if throttle > 0.8:
                load_factor += (throttle - 0.8) * 0.5 
                
            # Base highly-efficient BSFC is 240. Add efficiency penalties.
            dynamic_bsfc = 240.0 + (rpm_factor * 80.0) + (load_factor * 150.0)
            
            flow_l_s = (power_kw * dynamic_bsfc / 3600) / 740
            idle_flow = 0.8 / 3600 
            
            # Deceleration Fuel Cut-Off (DFCO)
            if throttle == 0 and self.engine.rpm > self.engine.idle_rpm + 200:
                self.instant_fuel_l_s = 0.0
            else:
                self.instant_fuel_l_s = max(idle_flow, flow_l_s)
                
        speed_kmh = abs(self.velocity * 3.6)
        current_unit = "L/100km" if speed_kmh > 5.0 else "L/h"
        
        if current_unit != self.fuel_display_unit:
            self.fuel_history.clear()
            self.fuel_display_unit = current_unit
            
        if current_unit == "L/100km":
            # As speed_kmh increases, this fraction gets smaller, dropping consumption
            raw_display_val = (self.instant_fuel_l_s * 3600) / speed_kmh * 100
            raw_display_val = min(99.9, raw_display_val)
        else:
            raw_display_val = self.instant_fuel_l_s * 3600

        self.fuel_history.append(raw_display_val)
        if len(self.fuel_history) > 0:
            self.fuel_display_val = sum(self.fuel_history) / len(self.fuel_history)

        # --- Calculate Drive Forces ---
        if is_in_neutral:
            force_drive = 0.0
        else:
            total_ratio = self.gearbox.get_total_ratio()
            torque_at_wheels = clutch_load_torque * total_ratio * 0.90
            force_drive = torque_at_wheels / self.wheel_radius
        
        # --- Environment & Resistance Forces ---
        slope_rad = math.radians(self.slope_angle)
        force_gravity = self.mass * 9.81 * math.sin(slope_rad)
        force_drag = 0.5 * 1.225 * self.frontal_area * self.drag_coeff * self.velocity * abs(self.velocity)
        
        if abs(self.velocity) > 0.1:
            direction = math.copysign(1, self.velocity)
            force_rr = 200 * math.cos(slope_rad) * direction
            force_brake = brake * self.brake_strength * direction
        else:
            force_rr = 0.0
            force_brake = 0.0
            if brake > 0.1:
                self.velocity = 0.0
                force_drive = 0.0 
                force_gravity = 0.0 
            
        force_total = force_drive - force_gravity - force_drag - force_rr - force_brake
        
        accel = force_total / self.mass
        self.velocity += accel * dt