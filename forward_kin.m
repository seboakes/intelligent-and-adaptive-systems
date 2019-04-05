%%Fucntion that takes joint angles, computes Forward Kinematics for a 3R
%%planar arm

function [X,Y] = forward_kin(theta1,theta2,theta3)

global L1 L2 L3;

            X = (L1*cos(theta1))+(L2*cos(theta1+theta2))+(L3*cos(theta1+theta2+theta3));          % compute x coordinates 
            Y = (L1*sin(theta1))+(L2*sin(theta1+theta2))+(L3*sin(theta1+theta2+theta3)); % compute y coordinates

end
