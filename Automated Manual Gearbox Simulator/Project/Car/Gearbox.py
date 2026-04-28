class Gearbox:
    def __init__(self):
        # Factory specifications for Toyota EC60 6-Speed Manual (1.8L)
        self.gears = {
             0:  0.0,    # Neutral: Disconnected
             1:  3.538,  # 1st: Short ratio for launch and hill starts
             2:  1.913,  # 2nd: City driving acceleration
             3:  1.310,  # 3rd: Merging and moderate speeds
             4:  0.971,  # 4th: Direct drive (nearly 1:1)
             5:  0.818,  # 5th: First overdrive
             6:  0.700   # 6th: Second overdrive for highway cruising
        }
        self.current_gear = 0
        
        # Factory Final Drive (Differential) ratio
        self.final_drive = 4.214 

    def shift_up(self):
        if self.current_gear < 6:
            self.current_gear += 1

    def shift_down(self):
        if self.current_gear > 0:
            self.current_gear -= 1

    def get_total_ratio(self):
        """Returns the combined ratio of the current gear and the differential."""
        return self.gears[self.current_gear] * self.final_drive