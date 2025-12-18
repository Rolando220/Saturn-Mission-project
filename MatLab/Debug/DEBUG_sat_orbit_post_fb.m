%% PLOT 2D: Confronto Orbita Post-Flyby vs SATURNO (Target Esterno)
try
    % 1. DATI ORBITA ATTUALE
    orb_new = sat.orbit_post_mars_fb;
    a_new = orb_new.a;
    e_new = orb_new.e;
    
    % Gestione ArgP
    if isnan(orb_new.argp), w_plot = 0; else, w_plot = orb_new.argp; end

    % 2. FIGURA
    figure('Name', 'Check Missione Saturno', 'Color', 'w'); clf; hold on;
    axis equal; grid on;
    xlabel('X [AU] (J2000)'); ylabel('Y [AU] (J2000)');
    title({'Analisi Traiettoria per Saturno', ...
           sprintf('Tua Orbita a = %.3f AU (Target Saturno a ~ 9.58 AU)', a_new)});

    % 3. RIFERIMENTI (Il Sole e i Target)
    theta_ref = linspace(0, 360, 360);
    
    % SOLE
    plot(0, 0, 'y.', 'MarkerSize', 40, 'DisplayName', 'Sole');

    % ORBITA MARTE (Partenza - Rossa)
    r_mars_ref = 1.52; 
    plot(r_mars_ref * cosd(theta_ref), r_mars_ref * sind(theta_ref), ...
         'r--', 'LineWidth', 1, 'DisplayName', 'Orbita Marte (Start)');

    % ORBITA SATURNO (Target - Nera/Oro)
    % Saturno orbita mediamente a 9.58 AU
    r_saturn_ref = 9.58; 
    plot(r_saturn_ref * cosd(theta_ref), r_saturn_ref * sind(theta_ref), ...
         'k-', 'LineWidth', 2, 'Color', [0.85 0.65 0.13], 'DisplayName', 'Orbita Saturno (Target)');

    % 4. TUA NUOVA ORBITA (Blu)
    % Generazione punti
    if e_new < 1
        % Ellisse
        p = a_new * (1 - e_new^2);
        theta_vec = linspace(0, 360, 360);
        orbit_type = 'Ellisse';
    else
        % Iperbole
        beta = acosd(-1/e_new); 
        theta_vec = linspace(-beta+5, beta-5, 200);
        p = abs(a_new * (1 - e_new^2));
        orbit_type = 'Iperbole';
    end
    
    r_draw = p ./ (1 + e_new * cosd(theta_vec));
    x_draw = r_draw .* cosd(theta_vec);
    y_draw = r_draw .* sind(theta_vec);

    % Rotazione
    x_final = x_draw * cosd(w_plot) - y_draw * sind(w_plot);
    y_final = x_draw * sind(w_plot) + y_draw * cosd(w_plot);

    plot(x_final, y_final, 'b-', 'LineWidth', 2, 'DisplayName', 'Nuova Orbita Sonda');

    % Posizione Attuale
    if exist('r_sat_marsfb_sp', 'var')
        plot(r_sat_marsfb_sp(1), r_sat_marsfb_sp(2), 'bo', 'MarkerFaceColor', 'cyan', 'DisplayName', 'Posizione Attuale');
    end

    legend('Location', 'bestoutside');
    
    % 5. ANALISI DI FATTIBILITÀ (Il verdetto)
    if e_new < 1
        r_aphelion = a_new * (1 + e_new); % Punto più lontano dal Sole
    else
        r_aphelion = Inf; % Se è iperbolica, va all'infinito (quindi raggiunge Saturno sicuro)
    end
    
    fprintf('\n--- ANALISI MISSIONE: MARTE -> SATURNO ---\n');
    fprintf('Tuo Afelio (punto più lontano): %.4f AU\n', r_aphelion);
    fprintf('Distanza media Saturno:         9.5800 AU\n');
    
    % Check: Saturno al perielio è a circa 9.0 AU, all'afelio a 10.0 AU.
    % Usiamo 9.0 come soglia minima di ottimismo.
    if r_aphelion >= 9.0
        fprintf('\n[SUCCESS] L''orbita raggiunge la distanza di Saturno!\n');
        fprintf('Hai abbastanza energia per un trasferimento verso i giganti gassosi.\n');
    else
        missing_au = 9.58 - r_aphelion;
        fprintf('\n[FAILURE] L''orbita è TROPPO CORTA.\n');
        fprintf('Ti mancano ancora %.2f AU per arrivare a Saturno.\n', missing_au);
        fprintf('Il Fly-by ti ha accelerato, ma non abbastanza.\n');
        
        % Stima di quanto a servirebbe
        % Per andare da Marte (1.5) a Saturno (9.5), a deve essere (1.5+9.5)/2 = 5.5 AU
        fprintf('Nota: Per arrivare a Saturno ti servirebbe un semiasse "a" di circa 5.5 AU.\n');
    end

catch ME
    warning('Errore plot: %s', ME.message);
end