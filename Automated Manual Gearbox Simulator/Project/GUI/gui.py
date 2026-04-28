import pygame
import math
from .graph import TimeGraph

WIDTH, HEIGHT = 1500, 600 
BLACK = (20, 20, 20)
DARK_GRAY = (40, 40, 40)
GRAY = (100, 100, 100)
WHITE = (220, 220, 220)
RED = (200, 50, 50)
ORANGE = (220, 140, 50)
GREEN = (50, 200, 50)
BLUE = (50, 100, 255)
PURPLE = (150, 50, 200)

class GUI:
    def __init__(self):
        pygame.font.init()
        self.font_sm = pygame.font.SysFont("Consolas", 14)
        self.font_md = pygame.font.SysFont("Consolas", 18, bold=True)
        self.font_lg = pygame.font.SysFont("Consolas", 30, bold=True)
        self.font_xl = pygame.font.SysFont("Consolas", 80, bold=True)
        
        self.filtered_rpm = 0.0 
        
        self.rpm_graph = TimeGraph("Engine RPM", 0, 8000, ORANGE)
        self.speed_graph = TimeGraph("Speed (km/h)", -20, 200, BLUE)
        self.gear_graph = TimeGraph("Gear (N to 6)", 0, 6, GREEN)

    def draw(self, screen, car, inputs, agent_data=None):
        self.filtered_rpm += (car.engine.rpm - self.filtered_rpm) * 0.15 
        
        self.rpm_graph.update(car.engine.rpm)
        self.speed_graph.update(car.velocity * 3.6)
        
        display_gear = max(0, car.gearbox.current_gear)
        self.gear_graph.update(display_gear)

        screen.fill(BLACK)

        self._draw_agent_debug_panel(screen, 0, 0, 300, HEIGHT, agent_data)

        OFFSET_X = 300
        pygame.draw.rect(screen, DARK_GRAY, (OFFSET_X, 450, 800, 150))
        pygame.draw.line(screen, GRAY, (OFFSET_X, 450), (OFFSET_X + 800, 450), 3)

        # Dynamically fetch redline, defaulting to 500 RPM below the hard limit if not defined
        redline = getattr(car.engine, 'redline_rpm', car.engine.limit_rpm - 500)
        
        self._draw_tachometer(screen, OFFSET_X + 250, 300, 130, self.filtered_rpm, car.engine.limit_rpm, redline)
        self._draw_speedometer(screen, OFFSET_X + 550, 280, car.velocity, car)
        self._draw_gear_box(screen, OFFSET_X + 420, 200, car.gearbox.current_gear)
        self._draw_pedals(screen, OFFSET_X + 500, 470, inputs)
        self._draw_slope_gauge(screen, OFFSET_X + 150, 520, car.slope_angle)
        
        status_color = GREEN if car.engine.running else RED
        status_text = "ENGINE ON" if car.engine.running else "STALLED"
        screen.blit(self.font_md.render(status_text, True, status_color), (OFFSET_X + 20, 20))

        self._draw_telemetry_panel(screen, 1100, 0, 400, HEIGHT)

    def _draw_agent_debug_panel(self, surface, x, y, w, h, agent_data):
        pygame.draw.rect(surface, (15, 20, 25), (x, y, w, h))
        pygame.draw.line(surface, GRAY, (x + w - 1, 0), (x + w - 1, h), 3)
        
        surface.blit(self.font_lg.render("AGENT BRAIN", True, WHITE), (x + 20, 20))
        
        if not agent_data:
            surface.blit(self.font_md.render("Awaiting connection...", True, GRAY), (x + 20, 70))
            return

        text_y = 80
        def add_text(label, value_str, color=WHITE):
            nonlocal text_y
            surface.blit(self.font_sm.render(label, True, GRAY), (x + 20, text_y))
            surface.blit(self.font_md.render(value_str, True, color), (x + 20, text_y + 18))
            text_y += 55

        add_text("FSM State:", f"{agent_data.get('state_name', 'UNKNOWN')}", ORANGE)
        add_text("Target Speed:", f"{agent_data.get('target_speed', 0.0):.1f} km/h", BLUE)
        add_text("Clutch Position:", f"{agent_data.get('clutch', 0.0):.2f}", PURPLE)
        add_text("Throttle Output:", f"{agent_data.get('throttle', 0.0):.2f}", GREEN)
        
        # --- Draw Interactive Input Box ---
        box_y = h - 90
        input_active = agent_data.get('input_active', False)
        
        bg_color = (40, 40, 50) if input_active else (20, 20, 25)
        border_color = WHITE if input_active else GRAY
        
        pygame.draw.rect(surface, bg_color, (x + 20, box_y, w - 40, 40))
        pygame.draw.rect(surface, border_color, (x + 20, box_y, w - 40, 40), 2)
        surface.blit(self.font_sm.render("Set Target Speed (km/h) [Click to Type]:", True, GRAY), (x + 20, box_y - 20))
        
        display_text = agent_data.get('input_text', "")
        # Add a blinking cursor effect if active
        if input_active and pygame.time.get_ticks() % 1000 < 500:
            display_text += "|"
            
        surface.blit(self.font_md.render(display_text, True, WHITE), (x + 30, box_y + 10))

    def _draw_telemetry_panel(self, surface, x, y, w, h):
        pygame.draw.rect(surface, (15, 15, 20), (x, y, w, h))
        pygame.draw.line(surface, GRAY, (x, 0), (x, h), 3)
        
        surface.blit(self.font_lg.render("LIVE TELEMETRY", True, WHITE), (x + 20, 20))
        
        self.rpm_graph.draw(surface, x + 20, 70, w - 40, 150)
        self.speed_graph.draw(surface, x + 20, 240, w - 40, 150)
        self.gear_graph.draw(surface, x + 20, 410, w - 40, 150)

    def _draw_tachometer(self, surface, x, y, radius, rpm, max_rpm, redline_rpm):
        pygame.draw.circle(surface, (10, 10, 10), (x, y), radius)
        pygame.draw.circle(surface, GRAY, (x, y), radius, 3) 
        
        start_angle = 225
        total_angle = 270
        
        # Draw ticks dynamically based on max_rpm
        for i in range(0, int(max_rpm) + 1, 250):
            is_major = (i % 1000 == 0)
            ratio = i / max_rpm
            angle_deg = start_angle - (ratio * total_angle)
            angle_rad = math.radians(angle_deg)
            
            outer_r = radius - 5
            inner_r = radius - (20 if is_major else 10)
            
            start_pos = (x + inner_r * math.cos(angle_rad), y - inner_r * math.sin(angle_rad))
            end_pos = (x + outer_r * math.cos(angle_rad), y - outer_r * math.sin(angle_rad))
            
            color = RED if i >= redline_rpm else WHITE
            width = 3 if is_major else 1
            pygame.draw.line(surface, color, start_pos, end_pos, width)
            
            if is_major:
                num_r = radius - 40
                num_x = x + num_r * math.cos(angle_rad)
                num_y = y - num_r * math.sin(angle_rad)
                num_str = str(int(i / 1000))
                text = self.font_md.render(num_str, True, color)
                text_rect = text.get_rect(center=(num_x, num_y))
                surface.blit(text, text_rect)

        rpm_clamped = min(rpm, max_rpm)
        needle_angle_deg = start_angle - ((rpm_clamped / max_rpm) * total_angle)
        needle_rad = math.radians(needle_angle_deg)
        
        needle_len = radius - 15
        end_x = x + needle_len * math.cos(needle_rad)
        end_y = y - needle_len * math.sin(needle_rad)
        
        pygame.draw.line(surface, ORANGE, (x, y), (end_x, end_y), 4)
        pygame.draw.circle(surface, (50, 50, 50), (x, y), 10)
        
        lbl = self.font_sm.render("RPM x1000", True, GRAY)
        surface.blit(lbl, (x - 40, y + 60))

    def _draw_speedometer(self, surface, x, y, velocity, car=None):
        speed_kmh = int(velocity * 3.6)
        color = WHITE if speed_kmh >= 0 else RED 
        txt = self.font_xl.render(f"{speed_kmh}", True, color)
        surface.blit(txt, (x, y))
        surface.blit(self.font_sm.render("km/h", True, GRAY), (x + 10, y + 60))

        if car is not None and hasattr(car, 'fuel_display_val'):
            fuel_y = y + 90
            pygame.draw.rect(surface, (30, 30, 30), (x, fuel_y, 140, 35), border_radius=5)
            pygame.draw.rect(surface, GRAY, (x, fuel_y, 140, 35), 1, border_radius=5)
            
            val_str = f"{car.fuel_display_val:.1f}"
            unit_str = getattr(car, 'fuel_display_unit', "L/h")
            
            fuel_color = GREEN if car.fuel_display_val < 0.1 and speed_kmh > 5 else ORANGE
            surface.blit(self.font_md.render(val_str, True, fuel_color), (x + 10, fuel_y + 8))
            surface.blit(self.font_sm.render(unit_str, True, GRAY), (x + 60, fuel_y + 10))

    def _draw_gear_box(self, surface, x, y, gear):
        pygame.draw.rect(surface, (30, 30, 30), (x, y, 100, 100), border_radius=10)
        pygame.draw.rect(surface, WHITE, (x, y, 100, 100), 2, border_radius=10)
        
        g_str = "N"
        color = GREEN
        
        if gear > 0:
            g_str = str(gear)
            color = ORANGE
            
        txt = self.font_lg.render(g_str, True, color)
        text_rect = txt.get_rect(center=(x + 50, y + 50))
        surface.blit(txt, text_rect)

    def _draw_pedals(self, surface, x, y, inputs):
        self._draw_single_bar(surface, x, y, "CLUTCH", inputs['clutch'], BLUE)
        self._draw_single_bar(surface, x + 80, y, "BRAKE", inputs['brake'], RED)
        self._draw_single_bar(surface, x + 160, y, "GAS", inputs['throttle'], GREEN)

    def _draw_single_bar(self, surface, x, y, label, value, color):
        lbl = self.font_sm.render(label, True, GRAY)
        surface.blit(lbl, (x, y))
        pygame.draw.rect(surface, (30, 30, 30), (x + 10, y + 25, 30, 100))
        height = value * 100
        pygame.draw.rect(surface, color, (x + 10, y + 25 + (100 - height), 30, height))
        pygame.draw.rect(surface, GRAY, (x + 10, y + 25, 30, 100), 1)

    def _draw_slope_gauge(self, surface, x, y, angle):
        pygame.draw.circle(surface, (30, 30, 30), (x, y), 50)
        pygame.draw.circle(surface, GRAY, (x, y), 50, 2)
        rad = math.radians(angle)
        start_x = x - 40 * math.cos(rad)
        start_y = y + 40 * math.sin(rad)
        end_x = x + 40 * math.cos(rad)
        end_y = y - 40 * math.sin(rad)
        pygame.draw.line(surface, GREEN, (start_x, start_y), (end_x, end_y), 3)
        surface.blit(self.font_sm.render(f"{angle:.1f}°", True, WHITE), (x - 20, y + 60))