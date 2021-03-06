clear all; close all; clc;
% main function of SMD system
m = 1; c=5; k = 6;

% ----- PWM function parameters -----
A2 = 10; 
alpha = 0.5;
w2 = 10;
% -----------------------------------

t = 3; %sec

% ----- state space representation -----
f2 = @(t,X)[X(2);Force2(t,w2,alpha,A2)-6*X(1)-5*X(2)]; % PWM input
% --------------------------------------
ic = [4;2];
[ts,xs] = ode45(f2,[0,t],ic);

%% calcualte energy
T = 1/2*m*xs(:,2).^2;  % kinematic energy
V = 1/2*k*xs(:,1).^2;  % potential energy

% calculate force
% force = zeros(length(ts(:,1)),1);
% for i = 1 : length(ts(:,1))
%     force(i,1) = Force2(ts(i,1),alpha,w2,A2);
% end
% force_de(2:length(ts(:,1)),1) = force(2:end,1).*(xs(2:end,1)-xs(1:end-1,1));
% force_de(1,1) = 0;

% damping loss
loss(2:length(ts(:,1)),1) = -c.*xs(2:end,2).*(xs(2:end,1)-xs(1:end-1,1));
loss(1,1) = 0;

damp_loss = zeros(length(ts(:,1)),1);
% force_energy = zeros(length(ts(:,1)),1);
for i = 2 : length(ts(:,1))
%     force_energy(i,1) = force_energy(i-1,1) + force_de(i);
    damp_loss(i,1) = damp_loss(i-1,1) + loss(i); % damping loss
end

total_energy = T + V - damp_loss;
%% animation
% ----- calculate SMD animation parameters -----
mass_width = 2; mass_height = 5;
x_range = (max(xs(:,1))-min(xs(:,1)))+1;
x_mid = (max(xs(:,1))+min(xs(:,1)))/2; % set equilibrium point of system
equ_pt = [7/4*(x_range + 1) , mass_height/2];
% ----------------------------------------------

figure('Name','SMD system_PWM input','units','normalized','outerposition',[0 0 1 1])
subplot(2,3,3);
h1 = animatedline('Color','b','LineWidth',1);
axis([0 t 0 A2]);
title('f-t plot');
xlabel('t');
ylabel('f');

subplot(2,3,4);
h2 = animatedline('Color','b','LineWidth',1);
axis([0 t min(xs(:,1)) max(xs(:,1))]);
title('x-t plot');
xlabel('t');
ylabel('x');

subplot(2,3,5);
h3 = animatedline('Color','b','LineWidth',1);
axis([0 t min(xs(:,2)) max(xs(:,2))]);
title('v-t plot');
xlabel('t');
ylabel('v');

subplot(2,3,6);
h4 = animatedline('Color','b','LineWidth',1);
axis([min(xs(:,1)) max(xs(:,1)) min(xs(:,2)) max(xs(:,2))]);
title('phase portrait');
xlabel('x');
ylabel('v');

% ------ PWM input ------
for i=1:size(ts,1)
    subplot(2,3,[1,2]);
    PlotSMD([equ_pt(1)+xs(i)-x_mid,equ_pt(2)],equ_pt,mass_width,mass_height,x_range);
    title({['SMD system : m=',num2str(m),', c=',num2str(c),', k=', num2str(k)];['input: periodic squared wave -- ','A=',num2str(A2),', alpha=',num2str(alpha),', w=',num2str(w2)]});

    addpoints(h1,ts(i,1),Force2(ts(i,1),w2,alpha,A2));
    addpoints(h2,ts(i,1),xs(i,1));
    addpoints(h3,ts(i,1),xs(i,2));
    addpoints(h4,xs(i,1),xs(i,2));
    drawnow;
end

%% energy plot
figure('Name','SMD system_sine input_Energy plot','units','normalized','outerposition',[0 0 1 1])
plot(ts(:,1),T(:,1),'b','LineWidth',1,'DisplayName','kinematic energy'); hold on;
plot(ts(:,1),V(:,1),'Color',[0.4660 0.6740 0.1880],'LineWidth',1,'DisplayName','potential energy'); hold on;
plot(ts(:,1),damp_loss(:,1),'Color',[0.9290 0.6940 0.1250],'LineWidth',1,'DisplayName','damping loss energy'); hold on;
% plot(ts(:,1),loss(:,1),'Color',[0.8500 0.3250 0.0980],'LineWidth',1,'DisplayName','loss energy'); hold on;
plot(ts(:,1),total_energy(:,1),'r','LineWidth',1,'DisplayName','total energy'); hold off;
title('E-t');
xlabel('t(s)');
ylabel('energy(J)');
grid on;
legend

%% PWM function
function f = Force2(t,w,alpha,A2)
    tf = mod(t,2*pi/w);
    if tf <= alpha*2*pi/w;
        f = A2;
    else
        f = 0;
    end
end