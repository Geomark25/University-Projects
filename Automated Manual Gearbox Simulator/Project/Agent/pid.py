class PIDController:
    def __init__(self, kp, ki, kd, setpoint=0.0, integral_limit=1.0):
        self.kp = kp
        self.ki = ki
        self.kd = kd
        
        # Limit represents the max output contribution from Integral (1.0 = 100% throttle)
        self.integral_limit = integral_limit
        
        self.setpoint = setpoint
        self.integral = 0.0
        self.previous_error = 0.0

    def update(self, current_value, dt):
        error = self.setpoint - current_value
        
        # Proportional term
        p_out = self.kp * error
        
        # Integral term with Dynamic Anti-Windup Clamping
        if dt > 0:
            self.integral += error * dt
            
        if self.ki > 0:
            # Dynamically clamp the memory so it cannot bloat beyond the throttle's physical limit
            max_i_sum = self.integral_limit / self.ki
            self.integral = max(-max_i_sum, min(max_i_sum, self.integral))
        else:
            self.integral = 0.0
            
        i_out = self.ki * self.integral
        
        # Derivative term
        derivative = (error - self.previous_error) / dt if dt > 0 else 0.0
        d_out = self.kd * derivative
        self.previous_error = error
        
        # Total output
        output = p_out + i_out + d_out
        
        # Clamp output to valid physical range [0.0, 1.0]
        return max(0.0, min(1.0, output)), p_out, i_out, d_out

    def reset(self):
        self.integral = 0.0
        self.previous_error = 0.0