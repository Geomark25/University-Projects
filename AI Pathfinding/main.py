import os
import sys

import matplotlib as mpl
import matplotlib.pyplot as plt

try:
    mpl.use('Qt5Agg')
except ImportError:
    mpl.use('TkAgg')

from commonroad.common.file_reader import CommonRoadFileReader
from commonroad.visualization.mp_renderer import MPRenderer

# add current directory to python path for local imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from SMP.maneuver_automaton.maneuver_automaton import ManeuverAutomaton
from SMP.motion_planner.motion_planner import MotionPlanner
from SMP.motion_planner.plot_config import StudentScriptPlotConfig

def execute_and_log_scenario(scenario, planning_problem, automaton, config_plot, scenario_name, output_filename=None):
    """
    Executes selected planners for a given scenario, prints to console, and saves to file.
    """
    # Print and write scenario header
    header = f"================================================= // {scenario_name}\n"
    print(header, end="")
                

    # Comment out the planners which you don't want to execute
    planners_to_run = [
        #(MotionPlanner.IDDFS, {'time_pause': 0.01}),
        #(MotionPlanner.LRTAstar, {'time_pause': 0.01}),
    ]

    # comment the whole line below to disable Weighted A*. Change euclidean to true for euclidean heuristic, false for custom
    # use the range() function to choose which weight to apply to the algorithms
    planners_to_run.extend([(MotionPlanner.weighted_astar, {'time_pause': 0.01, 'w': w, 'euclidean': False}) for w in range(0, 1)])


    results = []
    for planner_factory, kwargs in planners_to_run:
        planner_instance = planner_factory(scenario=scenario, 
                                        planning_problem=planning_problem, 
                                        automaton=automaton, 
                                        plot_config=config_plot)
        
        result_output = planner_instance.execute_search(**kwargs)
        results.append(result_output)
        
    
    for res in results:
        print(res)

    if output_filename:
        with open(output_filename, 'a', encoding='utf-8') as file:
            file.write(header)
            for res in results:
                file.write(f"\n{res}\n\n")
def main():
    # configurations
    path_scenario = 'Scenarios/scenario3.xml'
    scenario_name = 'Scenario_3'
    file_motion_primitives = 'V_9.0_9.0_Vstep_0_SA_-0.2_0.2_SAstep_0.4_T_0.5_Model_BMW320i.xml'
    config_plot = StudentScriptPlotConfig(DO_PLOT=True)

    # load scenario and planning problem set
    scenario, planning_problem_set = CommonRoadFileReader(path_scenario).open()
    # retrieve the first planning problem
    planning_problem = list(planning_problem_set.planning_problem_dict.values())[0]

    # create maneuver automaton and planning problem
    automaton = ManeuverAutomaton.generate_automaton(file_motion_primitives)

    execute_and_log_scenario(scenario=scenario, planning_problem=planning_problem, 
                             automaton=automaton, config_plot=config_plot, scenario_name=scenario_name,
                             output_filename=f"{scenario_name}.txt"    #comment this line to disable file output
                             )

print('Done')

if __name__ == '__main__':
    main()
