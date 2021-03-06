function SMD_Sineinput(m,c,k,A,w,t,ic)
    % --------------------------------------
    % m: mass
    % c: damper coefficient
    % k: spring coefficient
    % A: amplitude of sine signal
    % w: frequency of sine signal
    % t: simulation time(sec)
    % ic: initial condition
    % --------------------------------------

    % ----- state space representation -----
    f1 = @(t,X)[X(2);1/m*Force1(t,w,A)-k/m*X(1)-c/m*X(2)]; % sin input
    % --------------------------------------

    clear ts xs;
    [ts,xs] = ode45(f1,[0,t],ic);

    % ----- calculate SMD animation parameters -----
    mass_width = 2; mass_height = 5;
    x_range = (max(xs(:,1))-min(xs(:,1)))+1;
    x_mid = (max(xs(:,1))+min(xs(:,1)))/2; % set equilibrium point of system
    equ_pt = [7/4*(x_range + 1) , mass_height/2];
    % ----------------------------------------------

    %% calcualte energy
    T = 1/2*m*xs(:,2).^2;  % kinematic energy
    V = 1/2*k*xs(:,1).^2;  % potential energy
    % damping loss
    loss(2:length(ts(:,1)),1) = -c.*xs(2:end,2).^2.*(ts(2:end,1)-ts(1:end-1,1));
    loss(1,1) = loss(2,1);

    for i = 1 : length(ts(:,1))
        damp_loss(i,1) = sum(loss(1:i,1)); % damping loss
    end

    total_energy = T + V - damp_loss; % total energy

    %% animation
    figure('Name','SMD system_sine input','units','normalized','outerposition',[0 0 1 1])
    subplot(2,3,3);
    h1 = animatedline('Color','b','LineWidth',1);
    axis([min(ts(:,1)) max(ts(:,1)) -A A]);
    title('f-t');
    xlabel('t(s)');
    ylabel('f');

    subplot(2,3,4);
    h2 = animatedline('Color','b','LineWidth',1);
    axis([0 t min(xs(:,1)) max(xs(:,1))]);
    title('x-t plot');
    xlabel('t(s)');
    ylabel('x');

    subplot(2,3,5);
    h3 = animatedline('Color','b','LineWidth',1);
    axis([0 t min(xs(:,2)) max(xs(:,2))]);
    title('v-t');
    xlabel('t(s)')
    ylabel('$\dot{x}$','interpreter','latex')

    subplot(2,3,6);
    h4 = animatedline('Color','b','LineWidth',1);
    axis([min(xs(:,1)) max(xs(:,1)) min(xs(:,2)) max(xs(:,2))]);
    title('phase portrait');
    xlabel('$x$','interpreter','latex')
    ylabel('$\dot{x}$','interpreter','latex')

    %----- one pulse sine function input ------
    for i=1:size(ts,1)
        subplot(2,3,[1,2]);
        PlotSMD([equ_pt(1)+xs(i)-x_mid,equ_pt(2)],equ_pt,mass_width,mass_height,x_range);
        title({['SMD system : m=',num2str(m),', c=',num2str(c),', k=', num2str(k), '  /  initial condition: x(0)=',num2str(ic(1)),', v(0)=',num2str(ic(2)) ];['input: single sinusoidal wave -- ','A=',num2str(A),', w=',num2str(w)]});

        addpoints(h1,ts(i,1),Force1(ts(i,1),w,A));
        addpoints(h2,ts(i,1),xs(i,1));
        addpoints(h3,ts(i,1),xs(i,2));
        addpoints(h4,xs(i,1),xs(i,2));
        drawnow;
    end

    %% energy plot
    figure('Name','SMD system_sine input_Eneryg plot','units','normalized','outerposition',[0 0 1 1])
    plot(ts(:,1),T(:,1),'b','LineWidth',1,'DisplayName','kinematic energy'); hold on;
    plot(ts(:,1),V(:,1),'Color',[0.4660 0.6740 0.1880],'LineWidth',1,'DisplayName','potential energy'); hold on;
    plot(ts(:,1),damp_loss(:,1),'Color',[0.9290 0.6940 0.1250],'LineWidth',1,'DisplayName','damping loss energy'); hold on;
    plot(ts(:,1),total_energy(:,1),'r','LineWidth',1,'DisplayName','total energy'); hold off;
    title({['SMD system : m=',num2str(m),', c=',num2str(c),', k=', num2str(k), '  /  initial condition: x(0)=',num2str(ic(1)),', v(0)=',num2str(ic(2))];['input: single sinusoidal wave -- ','A=',num2str(A),', w=',num2str(w)];['E-t']});
    xlabel('t(s)');
    ylabel('energy');
    legend
end

%% one pulse sine function
function f = Force1(t,w,A)
    if t <= 2*pi/w;
        f = A*sin(w*t);
    else
        f = 0;
    end
end