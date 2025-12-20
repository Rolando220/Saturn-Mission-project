%% PLOT 2D: Traiettoria MARS-CENTERED (Fly-by in km)
try
    % 1. SETUP FIGURA
    figure('Name', 'Fly-by Marte (Mars-Centered)', 'Color', 'w'); clf; hold on
    axis equal; grid on;
    xlabel('X [km]'); ylabel('Y [km]');
    title('Dettaglio Fly-by (Sistema relativo centrato su Marte)');
    % 2. DISEGNA MARTE (Corpo fisico) - Metodo con FILL (compatibile con legenda)
    % Creiamo i punti del cerchio
    theta_body = linspace(0, 2*pi, 100);
    
    x_mars_body = R_mars * cos(theta_body);
    y_mars_body = R_mars * sin(theta_body);
    
    % Usiamo fill: X, Y, Colore
    fill(x_mars_body, y_mars_body, [0.8 0.4 0.4], ...
         'EdgeColor', 'none', ...
         'DisplayName', 'Marte (Body)');
    
    % 3. DISEGNA SOI MARTE (Confine)
    theta = linspace(0, 2*pi, 200);
    plot(soi_mars * cos(theta), soi_mars * sin(theta), 'm--', 'LineWidth', 1, 'DisplayName', 'Mars SOI (577k km)');
    % 4. TRAIETTORIA SATELLITE (Già in km e centrata su Marte)
    % Assumiamo che 'state_sat_mars_escap' contenga [Rx Ry Rz Vx Vy Vz] in km e km/s
    sat_pos_km = state_sat_mars_escape(:, 1:3);
    
    plot(sat_pos_km(:,1), sat_pos_km(:,2), 'g-', 'LineWidth', 1.5, 'DisplayName', 'Traiettoria Sonda');
    % 5. PUNTI CHIAVE
    % Ingresso (Primo punto)
    plot(sat_pos_km(1,1), sat_pos_km(1,2), 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'Ingresso SOI');
    % Fine Propagazione (Ultimo punto)
    plot(sat_pos_km(end,1), sat_pos_km(end,2), 'kx', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Fine Sim');
    % 6. VETTORI VELOCITÀ (Quiver)
    try
        % A. Direzione moto di Marte (Dov'è che sta andando il pianeta?)
        % Convertiamo v_mars_sp da AU/s a km/s per coerenza fisica
        au_km = 149597870.7;
        v_mars_km_s = v_mars_sp * au_km;
        
        % Scaliamo la freccia per renderla visibile nel grafico (es. lunga 1/3 della SOI)
        scale_arrow = soi_mars / 2;
        
        % Vettore unitario direzione Marte
        dir_mars = v_mars_km_s / norm(v_mars_km_s);
        
        % Disegnamo la freccia partendo dal centro (0,0)
        quiver(0, 0, dir_mars(1)*scale_arrow, dir_mars(2)*scale_arrow, 0, ...
               'Color', 'm', 'LineWidth', 2, 'MaxHeadSize', 0.5, 'DisplayName', 'Direzione Moto Marte (Elio)');
           
        % B. Velocità Sonda all'ingresso
        v_sat_entry = state_sat_mars_escap(1, 4:6); % Velocità relativa in km/s
        dir_sat = v_sat_entry / norm(v_sat_entry);
        
        quiver(sat_pos_km(1,1), sat_pos_km(1,2), dir_sat(1)*scale_arrow, dir_sat(2)*scale_arrow, 0, ...
               'Color', 'g', 'LineWidth', 1.5, 'MaxHeadSize', 0.5, 'DisplayName', 'V_{sat} Relativa');
           
    catch
        % Ignora se mancano dati vettoriali
    end
    legend('Location', 'bestoutside');
    
    % 7. ANALISI AL VOLO (Stampa in console)
    dists = vecnorm(sat_pos_km, 2, 2); % Distanza punto per punto
    [min_dist, idx_min] = min(dists);
    fprintf('\n--- FLY-BY REPORT ---\n');
    fprintf('Minima distanza dal centro: %.2f km\n', min_dist);
    fprintf('Altitudine al Periasse:     %.2f km\n', min_dist - r_mars_body);
    
    % Se la distanza minima è quasi uguale all'ultimo punto, vuol dire che
    % non abbiamo ancora raggiunto il periasse o ci siamo fermati esattamente lì.
    if idx_min == length(dists)
        fprintf('NOTA: La simulazione si è fermata esattamente al periasse.\n');
    else
        fprintf('NOTA: Il periasse è stato superato (la sonda si sta allontanando).\n');
    end
catch ME
    % Corretto l'errore di sintassi nel warning
    warning('MATLAB:PlotError', 'Impossibile creare il plot Mars-Centered: %s', ME.message);
end




fprintf('\n============= EARTH-EARTH CRUISE PHASE REPORT =============\n');
fprintf('Time of Flight: %.2f days\n', (t_vec_cruise_earth_earth(end) - t_vec_cruise_earth_earth(1)) / 86400);
if dist_from_earth < soi_earth
    fprintf('SUCCESS: Spacecraft successfully entered Earth''s SOI!\n');
else
    fprintf('WARNING: Spacecraft arrived outside the SOI.\n');
    fprintf('Miss distance from SOI boundary: %.2f km\n', dist_from_earth - soi_earth);
end
fprintf('===========================================================\n');






