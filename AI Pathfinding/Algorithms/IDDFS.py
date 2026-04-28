from Algorithms.Utils.SequentialSearch import SequentialSearch
from SMP.motion_planner.plot_config import DefaultPlotConfig

class IDDFS(SequentialSearch):
    """
    Class for Iterative Deepening Depth First Search algorithm.
    """

    def __init__(self, scenario, planningProblem, automaton, plot_config=DefaultPlotConfig):
        super().__init__(scenario=scenario, planningProblem=planningProblem, automaton=automaton,
                         plot_config=plot_config)
        
    def DLS(self, node_current, depth):
        self.visited_count += 1
        # parse through all successors available starting from the current_node
        for primitive_successor in node_current.get_successors():

            # execute step from node_current to primitive_successor
            collision_flag, child = self.take_step(successor=primitive_successor, node_current=node_current)

            # if it collides with an obstacle or boundary skip this successor
            if collision_flag:
                continue

            # check whether goal is reached
            goal_flag = self.goal_reached(successor=primitive_successor, node_current=node_current)

            # if goal is reached, return back with the solution path
            if goal_flag:
                return True, depth, node_current
            
            # check if we have reached depth limit
            if depth == 0:
                goal_found = False
            else:
                # if goal is not reached, continue the search recursive
                goal_found, on_depth, node = self.DLS(node_current=child, depth=(depth-1))
            
             # if a recursive successor returns with goal reached and a solution path, no further recursion is required
            if goal_found:
                return True, on_depth, node
            
        return False, depth, node_current 

        
    def execute_search(self, time_pause):
        depth = 0
        node_initial = self.initialize_search(time_pause=time_pause)
        while True:
            found_path, on_depth, goal_node = self.DLS(node_current=node_initial, depth=depth)
            if found_path:
                return self.format_results("Iterative-Deepening DFS", goal_node)
            # check if asked depth limit is larger that tree's depth
            elif on_depth < depth:
                return self.format_results("Iterative-Deepening DFS", None)
            else:
                depth +=1