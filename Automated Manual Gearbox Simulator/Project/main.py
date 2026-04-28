import pygame
import sys
import argparse

from Car.Car_physics import CarPhysics
from GUI.gui import GUI
from Agent.fsm import AutoDriverFSM
from Controller import Controller

def main():
    parser = argparse.ArgumentParser(description="Multi-Mode Car Simulation")
    parser.add_argument('--manual', action='store_true', help='Run the simulation using manual keyboard controls')
    args = parser.parse_args()
    
    is_manual = args.manual

    pygame.init()
    screen = pygame.display.set_mode((1500, 600))
    pygame.display.set_caption("Hierarchical Agent - Multi-Mode Control")
    clock = pygame.time.Clock()

    gui = GUI()
    car = CarPhysics()
    
    # --- INITIALIZATION ---
    if is_manual:
        controller = Controller()
        agent = None
        print("Running in MANUAL mode.")
        print("Controls: W/S (Throttle/Brake), SPACE (Clutch), I (Ignition), A/D (Slope), UP/DOWN (Shift Gears)")
    else:
        agent = AutoDriverFSM(mode_name="NORMAL")
        controller = None
        print("Running in AUTONOMOUS mode.")

    dt = 1 / 60.0
    time_elapsed = 0.0
    step = 0

    input_rect = pygame.Rect(20, 600 - 90, 260, 40)
    input_active = False
    input_text = ""
    target_speed_kmh = 0.0

    running = True
    while running:
        time_elapsed += dt
        step += 1
        
        # --- 1. EVENT HANDLING ---
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            
            if event.type == pygame.MOUSEBUTTONDOWN:
                input_active = input_rect.collidepoint(event.pos)
                
            if event.type == pygame.KEYDOWN:
                if is_manual:
                    # Manual Mode: Discrete gear shifting using UP/DOWN arrows
                    if event.key == pygame.K_UP:
                        car.shift_gear(min(6, car.gearbox.current_gear + 1), controller.clutch)
                    elif event.key == pygame.K_DOWN:
                        car.shift_gear(max(0, car.gearbox.current_gear - 1), controller.clutch)
                else:
                    # Autonomous Mode: Set profiles and type target speed
                    if event.key == pygame.K_e:
                        agent.set_mode("ECO")
                    elif event.key == pygame.K_r:
                        agent.set_mode("NORMAL")
                    elif event.key == pygame.K_t:
                        agent.set_mode("SPORT")
                    
                    elif input_active:
                        if event.key == pygame.K_RETURN:
                            try:
                                target_speed_kmh = max(0.0, float(input_text))
                            except ValueError:
                                pass
                            input_text = "" 
                        elif event.key == pygame.K_BACKSPACE:
                            input_text = input_text[:-1]
                        else:
                            input_text += event.unicode

        # Continuous Slope Control
        if not is_manual:
            # Agent slope logic (UP/DOWN arrows)
            keys = pygame.key.get_pressed()
            if keys[pygame.K_UP]:
                car.slope_angle = min(30.0, car.slope_angle + (15.0 * dt))
            if keys[pygame.K_DOWN]:
                car.slope_angle = max(-30.0, car.slope_angle - (15.0 * dt))

        # --- 2. CONTROLLER / AGENT UPDATE ---
        if is_manual:
            inputs = controller.process_input(dt, car.gearbox)
            # The manual controller uses A/D for slope, apply it here
            car.slope_angle = inputs['slope'] 
            
            agent_data = {
                'state_name': "MANUAL CONTROL",
                'target_speed': 0.0,
                'clutch': inputs['clutch'],
                'throttle': inputs['throttle'],
                'input_active': False,
                'input_text': ""
            }
        else:
            inputs = agent.update(car, target_speed_kmh, dt, time_elapsed)
            
            agent_data = {
                'state_name': f"{agent.state} [{agent.mode.name}]",
                'target_speed': target_speed_kmh,
                'clutch': inputs['clutch'],
                'throttle': inputs['throttle'],
                'input_active': input_active,
                'input_text': input_text
            }

        # --- 3. PHYSICS UPDATE (The Car) ---
        car.update(dt, inputs)

        # --- 4. RENDER GUI ---
        gui.draw(screen, car, inputs, agent_data)
        pygame.display.flip()
        clock.tick(60) 

    pygame.quit()
    sys.exit()

if __name__ == "__main__":
    main()