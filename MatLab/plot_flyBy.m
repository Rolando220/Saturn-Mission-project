function plot_flyBy(t_vec, r_sat, soi_planet, v_planet, R_planet)
% PLOT_FLY-BY
%   - t_vec:        vettore tempi [s]
%   - r_sat:        posizione del satellite (3xN o Nx3) in km, relativo al centro Pianeta
%   - soi_planet    [km]
%   - v_planet:     [km/s] (3x1);
%


% Normalizza forma r_sat a 3xN
if size(r_sat,1) == 3
    R = r_sat;
else
    R = r_sat';
end

% 2D XY 
fig1 = figure('Name','FLY BY ');
title('Fly-by');

hold on; grid on; axis equal;
xlabel('X (km)'); ylabel('Y (km)');

% DISEGNO PIANETA (CORPO FISICO) 
    theta_body = linspace(0, 2*pi, 100);
    x_body = R_planet * cos(theta_body);
    y_body = R_planet * sin(theta_body);
    fill(x_body, y_body, [0.8 0.4 0.4], 'EdgeColor', 'none', 'DisplayName', ' Planet Body');

% DISEGNO SoI PIANETA  
    theta = linspace(0, 2*pi, 200);
    plot(soi_planet * cos(theta), soi_planet * sin(theta), 'k--', 'LineWidth', 1, 'DisplayName', 'Planet SOI');

%DISEGNO TRAIETTORIA SONDA 
    plot(R(1,:), R(2,:), 'g-', 'LineWidth', 1.5, 'DisplayName', 'Traiettoria Sonda');

%PUNTI CHIAVE 
    % Ingresso (Primo punto)
    plot(R(1,1), R(2,1), 'ob', 'MarkerFaceColor', 'b');
    text(R(1,1) + R(1,1)*0.06, R(2,1) + R(2,1)*0.06, 'Ingresso SoI', 'Color', 'b');
    % Usicta 
    plot(R(1,end), R(2,end), 'or', 'MarkerFaceColor', 'r');
    text(R(1,end) + R(1,end)*0.06, R(2,end) + R(2,end)*0.06, 'Uscita SoI', 'Color', 'r');
 
    

if nargin >= 4 && ~isempty(v_planet)
    v = v_planet(:);
    if norm(v) > 0
        v_dir = v / norm(v);
        arrow_len = soi_planet * 0.18;
        arrow2 = v_dir(1:2) * arrow_len;
        quiver(0,0, arrow2(1), arrow2(2), 0, 'k', 'LineWidth', 2, 'MaxHeadSize', 1);
        text(arrow2(1)*1.2, arrow2(2)*1.2, 'v_{Planet}', 'Color', 'k');
    end
end
    legend('Pianeta' ,'SoI','Traiettoria Sonda');
end
