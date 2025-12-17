function [value, isterminal, direction] = stopCondition(t, y, R_soi, mode)
    % STOPCONDITION Event function for ode45
    %
    % Inputs:
    %   t     - Time
    %   y     - State vector [rx, ry, rz, vx, vy, vz]
    %   R_soi - Radius of the Sphere of Influence (limit)
    %   mode  - String: 'exit' (stop at SOI border) or 'pericenter' (stop at closest approach)
    
    % Estrazione vettori
    r_vec = y(1:3);
    v_vec = y(4:6);
    
    current_dist = norm(r_vec);

    if strcmp(mode, 'exit')
        % --- MODO 1: Uscita dalla SOI ---
        % Cerchiamo quando la distanza eguaglia R_soi
        value = current_dist - R_soi;
        
        % Ferma l'integrazione
        isterminal = 1;
        
        % direction = 1: Ferma solo se la distanza sta aumentando (usciamo)
        direction = 1;
        
    elseif strcmp(mode, 'pericenter')
        % --- MODO 2: Punto di massimo avvicinamento ---
        % La derivata della distanza è zero quando r e v sono ortogonali.
        % Dot product: r * v
        value = dot(r_vec, v_vec);
        
        % Ferma l'integrazione
        isterminal = 1;
        
        % direction = 1: Ferma quando il prodotto scalare passa da negativo (avvicinamento)
        % a positivo (allontanamento). In pratica, ferma appena inizi a risalire.
        direction = 1;
        
    else
        error('Mode non riconosciuto. Usa "exit" o "pericenter".');
    end
end