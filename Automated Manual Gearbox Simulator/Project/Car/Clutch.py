import math

class Clutch:
    def __init__(self, max_torque_capacity=450, stiffness=10):
        self.max_capacity = max_torque_capacity
        self.stiffness = stiffness # How "bitey" it feels
        self.torque_transfer = 0.0

    def calculate_torque_transfer(self, engine_rpm, trans_input_rpm, pedal_position):
        """
        Calculates torque transfer between engine and transmission.
        pedal_position: 0.0 (Engaged) to 1.0 (Pressed/Disengaged)
        """
        # 1. Capacity reduces as pedal is pressed
        current_capacity = self.max_capacity * (1.0 - pedal_position)
        
        # 2. Speed difference
        slip_speed = engine_rpm - trans_input_rpm
        
        # 3. Friction Physics
        # If locked (low slip, high capacity), we act like a solid shaft (viscous)
        # If slipping, we act like a friction brake (Coulomb friction)
        
        if abs(slip_speed) < 50 and current_capacity > 50:
            # "Locked" mode simulation
            torque = slip_speed * self.stiffness
        else:
            # "Sliding" mode
            torque = math.copysign(current_capacity, slip_speed)
            
        # Clamp torque to capacity limits
        if abs(torque) > current_capacity:
             torque = math.copysign(current_capacity, torque)
             
        self.torque_transfer = torque
        return torque