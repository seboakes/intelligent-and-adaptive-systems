# intelligent-and-adaptive-systems
All code produced for the IAS module.

The general task given was to explore the use of the adaptive neuro-fuzzy inference systems (ANFIS) in robot arm control. The ANFIS system combines neural networks with fuzzy inference systems, to allow for the inference system to be tuned to its purpose automatically, without the knowledge of an expert operator.

This works well with a planar two link arm, allowing for the training of an inference system that can take similar x,y coordinates as the training data, and spit out joint angles that will give a good approximation to that desired coordinate. This method breaks down almost completely with the addition of a third link however; any one coordinate has an infinite multitude of potential solutions (a problem known as redundancy, common in robotics). Early exploration of this demonstrated that no amount of tweaking of the ANFIS system could yield results that even close to desirable.

Please read the report for my proposed solutions to this redundancy problem, and the results of such experimentation.
