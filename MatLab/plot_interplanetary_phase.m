function plot_interplanetary_phase(state_traj, tvec, depart_info, arrival_info, planets_elements, jd_start, soi_depart_km, soi_arrival_km, timezone, phase_label)
% PLOT_INTERPLANETARY_PHASE Plot a single interplanetary cruise phase.
% Styled after DEBUG_E_M.m: shows Sun, satellite trajectory, planet orbits, SOI circles, and velocity quivers.
%
% Inputs:
%   state_traj       - Nx6 matrix [rx ry rz vx vy vz] in AU and AU/s (satellite heliocentric state)
%   tvec             - Nx1 vector of times in seconds (absolute time = JD*86400)
%   depart_info      - struct: .name (string), .r_soi (3x1 AU), .v_soi (3x1 AU/s), .jd_soi (scalar JD)
%   arrival_info     - struct: .name (string), .r_arrival (3x1 AU), .v_arrival (3x1 AU/s), .jd_arrival (scalar JD)
%   planets_elements - struct with planet orbital elements (from elements_from_ephems)
%   jd_start         - mission epoch reference (Julian Date)
%   soi_depart_km    - departure planet SOI radius (km)
%   soi_arrival_km   - arrival planet SOI radius (km)
%   timezone         - (optional) timezone string for date printing (default 'UTC')
%   phase_label      - (optional) string label for the phase (default '')

if nargin < 9, timezone = 'UTC'; end
if nargin < 10, phase_label = ''; end

au = 149597870.7; % km

% Create figure
figure('Name', ['Interplanetary: ' phase_label], 'Color', 'w'); 
clf; hold on; grid on; axis equal;

% Sun
plot(0, 0, 'y*', 'MarkerSize', 12, 'DisplayName', 'Sun');

% Satellite trajectory
sat_pos_au = state_traj(:, 1:3); % Nx3 AU
plot(sat_pos_au(:,1), sat_pos_au(:,2), 'g-', 'LineWidth', 1.5, 'DisplayName', ['Trajectory ' phase_label]);

% Planet orbit arcs
theta = linspace(0, 2*pi, 240)';

% Departure planet orbit
if isfield(planets_elements, depart_info.name)
    try
        jd_vec_dep = jd_start:0.1:depart_info.jd_soi;
        [~, r_dep_traj, ~] = planet_orbit_coplanar(planets_elements.(depart_info.name), jd_start, depart_info.jd_soi, jd_vec_dep);
        plot(r_dep_traj(1,:), r_dep_traj(2,:), 'b--', 'LineWidth', 1.2, 'DisplayName', [upper(depart_info.name(1)) depart_info.name(2:end) ' orbit']);
    catch ME
        warning('Could not plot departure planet orbit: %s', ME.message);
    end
end

% Arrival planet orbit
if isfield(planets_elements, arrival_info.name)
    try
        jd_vec_arr = jd_start:0.1:arrival_info.jd_arrival;
        [~, r_arr_traj, ~] = planet_orbit_coplanar(planets_elements.(arrival_info.name), jd_start, arrival_info.jd_arrival, jd_vec_arr);
        plot(r_arr_traj(1,:), r_arr_traj(2,:), 'm--', 'LineWidth', 1.2, 'DisplayName', [upper(arrival_info.name(1)) arrival_info.name(2:end) ' orbit']);
    catch ME
        warning('Could not plot arrival planet orbit: %s', ME.message);
    end
end

% Key points
plot(depart_info.r_soi(1), depart_info.r_soi(2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'SOI exit');
plot(sat_pos_au(end,1), sat_pos_au(end,2), 'kx', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Sat arrival');
plot(arrival_info.r_arrival(1), arrival_info.r_arrival(2), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 8, 'DisplayName', [upper(arrival_info.name(1)) arrival_info.name(2:end) ' arrival']);

% SOI circles (2D projection)
soi_dep_au = soi_depart_km / au;
soi_arr_au = soi_arrival_km / au;
plot(depart_info.r_soi(1) + soi_dep_au*cos(theta), depart_info.r_soi(2) + soi_dep_au*sin(theta), 'b--', 'DisplayName', 'Depart SOI');
plot(arrival_info.r_arrival(1) + soi_arr_au*cos(theta), arrival_info.r_arrival(2) + soi_arr_au*sin(theta), 'm--', 'DisplayName', 'Arrival SOI');

% Velocity direction arrows (scaled for visibility)
try
    arrow_days = 5; % ~5 days displacement for visibility
    scale_seconds = 3600 * 24 * arrow_days;
    v_dep_vec = depart_info.v_soi(:) * scale_seconds; % AU
    v_arr_vec = arrival_info.v_arrival(:) * scale_seconds; % AU
    quiver(depart_info.r_soi(1), depart_info.r_soi(2), v_dep_vec(1), v_dep_vec(2), 0, 'b', 'LineWidth', 1.4, 'MaxHeadSize', 0.5);
    quiver(arrival_info.r_arrival(1), arrival_info.r_arrival(2), v_arr_vec(1), v_arr_vec(2), 0, 'm', 'LineWidth', 1.4, 'MaxHeadSize', 0.5);
    text(depart_info.r_soi(1) + v_dep_vec(1)*0.06, depart_info.r_soi(2) + v_dep_vec(2)*0.06, ['v_{' depart_info.name '}'], 'Color', 'b', 'FontSize', 9);
    text(arrival_info.r_arrival(1) + v_arr_vec(1)*0.06, arrival_info.r_arrival(2) + v_arr_vec(2)*0.06, ['v_{' arrival_info.name '}'], 'Color', 'm', 'FontSize', 9);
catch ME
    warning('Could not add velocity quivers: %s', ME.message);
end

xlabel('X [AU]'); ylabel('Y [AU]');
title(['Interplanetary: ' phase_label ' (XY projection)']);
legend('Location', 'best');

% Print dates
try
    fprintf('\n--- %s PHASE ---\n', upper(phase_label));
    fprintf('Departure: %s SOI at JD %.6f (%s)\n', depart_info.name, depart_info.jd_soi, ...
        datestr(datetime(depart_info.jd_soi,'convertfrom','juliandate','TimeZone',timezone)));
    fprintf('Arrival:   %s at JD %.6f (%s)\n', arrival_info.name, arrival_info.jd_arrival, ...
        datestr(datetime(arrival_info.jd_arrival,'convertfrom','juliandate','TimeZone',timezone)));
    fprintf('Duration:  %.2f days\n', (tvec(end) - tvec(1))/86400);
catch
end

end
