class DrivingMode:
    def __init__(self, name, target_rpm, max_accel, accel_rate, max_throttle, pid_kp, pid_ki, launch_rpm, max_eb_rpm):
        self.name = name
        self.target_rpm = target_rpm      
        self.max_accel = max_accel        
        self.accel_rate = accel_rate      
        self.max_throttle = max_throttle
        self.pid_kp = pid_kp
        self.pid_ki = pid_ki
        self.launch_rpm = launch_rpm
        self.max_eb_rpm = max_eb_rpm      # NEW: How high the engine is allowed to rev to slow the car down

MODES = {
    "ECO": DrivingMode(
        name="ECO", 
        target_rpm="MIN", 
        max_accel=1.0,
        accel_rate=0.15,
        max_throttle=0.85, 
        pid_kp=0.10, 
        pid_ki=0.04,  # Halved from 0.08
        launch_rpm=1500,
        max_eb_rpm=3000  
    ),
    
    "NORMAL": DrivingMode(
        name="NORMAL", 
        target_rpm=2800, 
        max_accel=1.8,
        accel_rate=0.20,
        max_throttle=1.0,   
        pid_kp=0.18, 
        pid_ki=0.06,  # Halved from 0.12
        launch_rpm=1800,
        max_eb_rpm=4500
    ),
    
    "SPORT": DrivingMode(
        name="SPORT", 
        target_rpm=4400, 
        max_accel=5.0,
        accel_rate=0.80,
        max_throttle=1.0, 
        pid_kp=0.60, 
        pid_ki=0.09,  # Reduced from 0.20
        launch_rpm=3500,
        max_eb_rpm=6500
    )
}