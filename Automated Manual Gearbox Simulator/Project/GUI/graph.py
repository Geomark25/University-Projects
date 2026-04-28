import pygame
import collections

WHITE = (220, 220, 220)

class TimeGraph:
    def __init__(self, title, min_val, max_val, color, history_len=150):
        self.title = title
        self.min_val = min_val
        self.max_val = max_val
        self.color = color
        self.data = collections.deque(maxlen=history_len)
        
        pygame.font.init()
        self.font = pygame.font.SysFont("Consolas", 12)
        self.font_bold = pygame.font.SysFont("Consolas", 14, bold=True)

    def update(self, value):
        self.data.append(value)

    def draw(self, surface, x, y, w, h):
        pygame.draw.rect(surface, (25, 25, 30), (x, y, w, h))
        pygame.draw.rect(surface, (100, 100, 100), (x, y, w, h), 1)
        
        surface.blit(self.font.render(self.title, True, WHITE), (x + 5, y + 2))
        surface.blit(self.font.render(str(self.max_val), True, (120, 120, 120)), (x + 5, y + 16))
        surface.blit(self.font.render(str(self.min_val), True, (120, 120, 120)), (x + 5, y + h - 16))

        if len(self.data) == 0:
            return

        current_val = self.data[-1]
        
        if "Gear" in self.title:
            val_str = "N" if current_val <= 0 else str(int(current_val))
        else:
            val_str = f"{int(current_val)}"
            
        box_w, box_h = 50, 22
        box_x, box_y = x + w - box_w - 5, y + 5
        
        pygame.draw.rect(surface, (40, 40, 50), (box_x, box_y, box_w, box_h))
        pygame.draw.rect(surface, self.color, (box_x, box_y, box_w, box_h), 1)
        
        text = self.font_bold.render(val_str, True, WHITE if "Gear" not in self.title else self.color)
        text_rect = text.get_rect(center=(box_x + box_w // 2, box_y + box_h // 2))
        surface.blit(text, text_rect)

        if len(self.data) < 2:
            return
            
        points = []
        step_x = w / self.data.maxlen
        val_range = self.max_val - self.min_val if self.max_val != self.min_val else 1
            
        for i, val in enumerate(self.data):
            px = x + (i * step_x)
            clamped = max(self.min_val, min(self.max_val, val))
            normalized = (clamped - self.min_val) / val_range
            py = y + h - (normalized * h)
            points.append((px, py))

        pygame.draw.lines(surface, self.color, False, points, 2)