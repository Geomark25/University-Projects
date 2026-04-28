
######################################################################################
#
#   Initial controller class, used to manually test the car physics and implementation
#
######################################################################################

import pygame

class Controller:
    def __init__(self):
        self.throttle = 0.0
        self.brake = 0.0
        self.clutch = 0.0
        self.ignition = False
        self.slope_cmd = 0.0
        
        # Input Smoothing speeds
        self.press_speed = 2.0
        self.release_speed = 3.0

    def process_input(self, dt, gearbox):
        keys = pygame.key.get_pressed()
        
        # Throttle (W)
        if keys[pygame.K_w]:
            self.throttle = min(1.0, self.throttle + self.press_speed * dt)
        else:
            self.throttle = max(0.0, self.throttle - self.release_speed * dt)
            
        # Brake (S)
        if keys[pygame.K_s]:
            self.brake = min(1.0, self.brake + self.press_speed * dt)
        else:
            self.brake = max(0.0, self.brake - self.release_speed * dt)
            
        # Clutch (Space)
        if keys[pygame.K_SPACE]:
            self.clutch = min(1.0, self.clutch + 5.0 * dt) # Clutch is fast
        else:
            self.clutch = max(0.0, self.clutch - 5.0 * dt)
            
        # Ignition (I)
        self.ignition = keys[pygame.K_i]
        
        # Slope (A/D)
        if keys[pygame.K_d]: self.slope_cmd += 10 * dt
        if keys[pygame.K_a]: self.slope_cmd -= 10 * dt
        self.slope_cmd = max(-25, min(25, self.slope_cmd))
        
        # Gear shifting is discrete, handled via event loop in main
        
        return {
            'throttle': self.throttle,
            'brake': self.brake,
            'clutch': self.clutch,
            'ignition': self.ignition,
            'slope': self.slope_cmd
        }