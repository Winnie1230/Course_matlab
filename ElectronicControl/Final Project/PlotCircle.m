function PlotCircle(x,y,r,c)
    th = 0:pi/50:2*pi;
    x_circle = r * cos(th) + x;
    y_circle = r * sin(th) + y;
    fill(x_circle, y_circle, c); hold on
    plot(x_circle, y_circle,'Color', c); hold off
%     axis equal
end