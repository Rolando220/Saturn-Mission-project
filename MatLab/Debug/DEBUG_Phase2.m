%% PHASE 2 - DEBUG: Simulazione trasferimento Terra-Marte
% -----------------------------------------------------------------------------------------------------------------------------------------------------
% PROPAGAZIONE E VISUALIZZAZIONE DELLA TRAIETTORIA
% -----------------------------------------------------------------------------------------------------------------------------------------------------

fprintf('\n========== PHASE 2 - TRASFERIMENTO TERRA-MARTE ==========\n')
fprintf('Data partenza: %s\n', datestr(start_date))
fprintf('Data arrivo Marte: %s\n', datestr(mars_fb_date))
fprintf('Tempo di volo: %.2f giorni (%.2f anni)\n', deltaT_earth_mars/(24*60*60), deltaT_earth_mars/(24*60*60*365.25))
fprintf('\nParametri traiettoria di trasferimento:\n')
fprintf('  a = %.4f AU\n', sat.orbit_transfer_earth_mars.a)
fprintf('  e = %.6f\n', sat.orbit_transfer_earth_mars.e)
fprintf('  i = %.4f°\n', sat.orbit_transfer_earth_mars.i)
fprintf('\nVelocità eliocentrica partenza: %.6f AU/s = %.4f km/s\n', norm(v_earth_sp_appr), norm(v_earth_sp_appr)*au)
fprintf('Velocità pianeta Terra: %.6f AU/s = %.4f km/s\n', norm(v_earth(:,1)), norm(v_earth(:,1))*au)
fprintf('Velocità eliocentrica arrivo: %.6f AU/s = %.4f km/s\n', norm(v_mars_sa_appr), norm(v_mars_sa_appr)*au)
fprintf('Velocità pianeta Marte: %.6f AU/s = %.4f km/s\n', norm(v_mars_fb), norm(v_mars_fb)*au)

% Velocità relative (v_inf)
v_inf_earth = norm(v_earth_sp_appr - v_earth(:,1));
v_inf_mars = norm(v_mars_sa_appr - v_mars_fb);
fprintf('\nV_inf Terra (partenza): %.6f AU/s = %.4f km/s\n', v_inf_earth, v_inf_earth*au)
fprintf('V_inf Marte (arrivo): %.6f AU/s = %.4f km/s\n', v_inf_mars, v_inf_mars*au)
fprintf('=========================================================\n\n')

% Propagazione della traiettoria di trasferimento
t_transfer = linspace(0, deltaT_earth_mars, 1000);
y0_transfer = [r_earth(:,1); v_earth_sp_appr];
options_transfer = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, y_transfer] = ode113(@(t, y) satellite_ode(t, y, mu_sun_au), t_transfer, y0_transfer, options_transfer);

% Calcola posizioni pianeti lungo l'arco temporale
jd_transfer = linspace(jd_start, jd_mars_fb, 100);
[~, r_earth_traj, ~] = planet_orbit_coplanar(planets_elements.earth, jd_start, jd_mars_fb, jd_transfer);
[~, r_mars_traj, ~] = planet_orbit_coplanar(planets_elements.mars, jd_start, jd_mars_fb, jd_transfer);
[~, r_venus_traj, ~] = planet_orbit_coplanar(planets_elements.venus, jd_start, jd_mars_fb, jd_transfer);

% Orbite complete pianeti
jd_full_orbit = linspace(jd_start, jd_start + 687, 500); % periodo Marte ~687 giorni
[~, r_earth_full, ~] = planet_orbit_coplanar(planets_elements.earth, jd_start, jd_start + 687, jd_full_orbit);
[~, r_mars_full, ~] = planet_orbit_coplanar(planets_elements.mars, jd_start, jd_start + 687, jd_full_orbit);
[~, r_venus_full, ~] = planet_orbit_coplanar(planets_elements.venus, jd_start, jd_start + 687, jd_full_orbit);

% GRAFICO: Vista nel piano dell'eclittica
figure('Name', 'Trasferimento Terra-Marte - Piano eclittico')
hold on

% Orbite pianeti (complete)
plot3(r_earth_full(1,:), r_earth_full(2,:), r_earth_full(3,:), 'b--', 'LineWidth', 1, 'DisplayName', 'Orbita Terra')
plot3(r_mars_full(1,:), r_mars_full(2,:), r_mars_full(3,:), 'r--', 'LineWidth', 1, 'DisplayName', 'Orbita Marte')
plot3(r_venus_full(1,:), r_venus_full(2,:), r_venus_full(3,:), 'y--', 'LineWidth', 0.5, 'DisplayName', 'Orbita Venere')

% Traiettoria satellite
plot3(y_transfer(:,1), y_transfer(:,2), y_transfer(:,3), 'g-', 'LineWidth', 2.5, 'DisplayName', 'Traiettoria satellite')

% Posizioni iniziali e finali
plot3(r_earth(1,1), r_earth(2,1), r_earth(3,1), 'bo', 'MarkerSize', 12, 'MarkerFaceColor', 'b', 'DisplayName', 'Terra (partenza)')
plot3(r_mars_fb(1), r_mars_fb(2), r_mars_fb(3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', 'Marte (arrivo)')

% Posizioni finali del satellite
plot3(y_transfer(end,1), y_transfer(end,2), y_transfer(end,3), 'mx', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Satellite (arrivo)')

% Sole al centro
plot3(0, 0, 0, 'yo', 'MarkerSize', 25, 'MarkerFaceColor', 'y', 'DisplayName', 'Sole')

grid on
axis equal
xlabel('X_{ecl} [AU]')
ylabel('Y_{ecl} [AU]')
zlabel('Z_{ecl} [AU]')
title('Trasferimento Terra-Marte')
legend('Location', 'best')
view(2) % Vista dall'alto (piano eclittico)

% Verifica distanza finale
dist_finale = norm(y_transfer(end,1:3)' - r_mars_fb);
fprintf('Distanza finale satellite-Marte: %.6f AU = %.2f km\n', dist_finale, dist_finale*au)
if dist_finale < 0.01 % < 0.01 AU ~ 1.5 milioni km
    fprintf('✓ ARRIVO A MARTE CORRETTO!\n\n')
else
    fprintf('⚠ ERRORE: Il satellite non arriva a Marte (distanza %.2f milioni di km)\n\n', dist_finale*au/1e6)
end