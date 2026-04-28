from Algorithms.Utils.SequentialSearch import SequentialSearch
from SMP.motion_planner.plot_config import DefaultPlotConfig
import math

class LRTAstar(SequentialSearch):
    """
    Class for LRTA* Search algorithm.
    """

    def __init__(self, scenario, planningProblem, automaton, plot_config=DefaultPlotConfig):
        super().__init__(scenario=scenario, planningProblem=planningProblem, automaton=automaton,
                         plot_config=plot_config)
        
        self.H_table = {}
    
    def execute_search(self, time_pause):
        node_current = self.initialize_search(time_pause=time_pause)
        node_current.cost = 0
        node_current.parent = None
        
        self.H_table.clear()

        while True:
            self.visited_count += 1

            current_state_info = self.get_node_information(node_current)
            current_state_key = tuple(round(coord, 4) for coord in current_state_info)

            min_f_value = float('inf')
            best_child = None
            valid_successors_count = 0

            for primitive_successor in node_current.get_successors():
                collision_flag, child = self.take_step(successor=primitive_successor, node_current=node_current)

                if collision_flag:
                    continue
                
                valid_successors_count += 1
                child.parent = node_current

                if self.goal_reached(successor=primitive_successor, node_current=node_current):
                    return self.format_results("LRTA*", node_current)

                child.cost = self.cost_function(child)
                step_cost = child.cost - node_current.cost
                f_value = step_cost + self.get_H_value(child)

                if f_value < min_f_value:
                    min_f_value = f_value
                    best_child = child

            if best_child is None:
                self.H_table[current_state_key] = float('inf')
                
                if node_current.parent is not None:
                    node_current = node_current.parent
                    continue
                else:
                   return self.format_results("LRTA*", None)

            old_h = self.H_table.get(current_state_key, "Unvisited")
                
            self.H_table[current_state_key] = min_f_value

            best_child_info = tuple(round(coord, 4) for coord in self.get_node_information(best_child))
            
            node_current = best_child
    
    def heuristic_function(self, node_current):
        node = self.get_node_information(node_current=node_current)
        goal = self.get_goal_information()

        x = goal[0] - node[0]
        y = goal[1] - node[1]

        distance = math.sqrt(x**2 + y**2)
        return distance
    
    def get_H_value(self, node_current):
        state_info = self.get_node_information(node_current=node_current)
        state_key = tuple(round(coord, 4) for coord in state_info)

        if state_key not in self.H_table:
            self.H_table[state_key] = self.heuristic_function(node_current=node_current)

        return self.H_table[state_key]
 