from Algorithms.Utils.SequentialSearch import SequentialSearch
from SMP.motion_planner.plot_config import DefaultPlotConfig
import math

class weighted_astar(SequentialSearch):
    """
    Class for Weighted A* Search algorithm.
    """

    def __init__(self, scenario, planningProblem, automaton, plot_config=DefaultPlotConfig):
        super().__init__(scenario=scenario, planningProblem=planningProblem, automaton=automaton,
                         plot_config=plot_config)
        
    def execute_search(self, time_pause, w, euclidean):

        node_initial = self.initialize_search(time_pause=time_pause)
        node_initial.cost = 0

        node_fn_list = [node_initial]

        while node_fn_list:

            
            stingiest_node = None
            stingiest_f = float('inf')

            for node in node_fn_list:

                g = node.cost
                if euclidean:
                    h = self.heuristic_function_euclidean(node)
                else:
                    h = self.heuristic_function(node)
                f = g + w * h

                if f < stingiest_f:
                    stingiest_f = f
                    stingiest_node = node

            node_current = stingiest_node
            node_fn_list.remove(node_current)
            self.visited_count += 1

            for primitive_successor in node_current.get_successors():

                collision_flag, child = self.take_step(primitive_successor, node_current)

                if collision_flag:
                    continue

                if self.goal_reached(primitive_successor, node_current):
                    return self.format_results(f"Weighted A* (w = {w})", node_current)

                node_fn_list.append(child)

        return self.format_results(f"Weighted A* (w = {w})", None)
    

    def heuristic_function_euclidean(self, node_current):
        node = self.get_node_information(node_current=node_current)
        goal = self.get_goal_information()

        x = goal[0] - node[0]
        y = goal[1] - node[1]

        distance = math.sqrt(x**2 + y**2)
        return distance
    
    def heuristic_function(self, node_current):
        node = self.get_node_information(node_current)
        goal = self.get_goal_information()

        nx, ny = node[0], node[1]
        gx, gy = goal[0], goal[1]

        dx_goal = gx - nx
        dy_goal = gy - ny
        base_h = math.hypot(dx_goal, dy_goal)


        obstacles = self.get_obstacles_information()

        clearance_bias = 0.0
        influence_radius = 6.0     # how far obstacle influence extends
        epsilon = 1e-6

        for obs in obstacles:
            obs_x, obs_y, obs_length, obs_width = obs[0], obs[1], obs[2], obs[3]


            dx = max(0.0, abs(nx - obs_x) - obs_length / 2.0)
            dy = max(0.0, abs(ny - obs_y) - obs_width / 2.0)
            dist = math.hypot(dx, dy)

            if dist < influence_radius:
                normalized = (influence_radius - dist) / influence_radius

                clearance_bias += normalized / (dist + 0.5)

        beta = 0.05

        heuristic = base_h * (1.0 + beta * clearance_bias)

        return heuristic