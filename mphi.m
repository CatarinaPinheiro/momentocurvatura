%base = 200
%altura = 650
%resistencia_concreto = 25
%resistencia_escoamento_aco = 500
%resistencia_ultima_aco = 600
%deformacao_ultima_aco = 0.05
%forca_dada = 4
%numero_camadas_aco = 0



curva = 2;
numero_camadas_concreto = 100; %N�mero de camadas de concreto
elem_area_concreto = altura*base/numero_camadas_concreto;
altura_elemento=zeros;
for i =1:numero_camadas_concreto
    altura_elemento(i) = ((altura/2)- (2*i -1)*altura/(2*numero_camadas_concreto));
end
%posicao_armadura= zeros;
%area_aco=zeros;
%influencia_protensao=zeros;
altura_elemento_aco=zeros;
for j = 1:numero_camadas_aco
    %    posicao_armadura(j) = input('Digite a posicao da respectiva camada de armadura ');
    %    elem_area_aco(j) =input(' Digite a area de armadura para a respectiva camada ');
    %influencia_protensao(j) = 0 % input('Digite a influ�ncia da protens�o para a respectiva camada');
    altura_elemento_aco(j) = altura/2 - posicao_armadura(j);
end

%%% Cálculo Deformação %%
numeroiteracoes = 50;
x = [];
y = [];

numeros=zeros(1,100);

for k = 1:35
    
    xmax = altura;
    xmin = 0;
    while xmax - xmin > 0.001
        xln = (xmax + xmin)/2;
        
        eps_max = k/10000;
        
        curvatura =-(eps_max)/xln;
        
        deformacao_centro_gravidade = eps_max + curvatura*(altura/2);
        
        for i = 1:numero_camadas_concreto
            deformacao_concreto(i) = deformacao_centro_gravidade - curvatura*altura_elemento(i);
        end
        % Deformação Aço %
        for j = 1:numero_camadas_aco
            deformacao_aco(j) = (deformacao_centro_gravidade - curvatura*altura_elemento_aco(j));
        end
        %% Curva Aço-Concreto %%
        %Curva Concreto
        if curva == 1 % ceb_ideal
            if resistencia_concreto < 50
                eps_c0 = 0.002
                eps_cmax = 0.0035
                for i = 1:numero_camadas_concreto
                    if deformacao_concreto(i) < 0.002
                        eps_razao = deformacao_concreto(i)/eps_c0;
                        tensao_concreto(i) = 0.85*resistencia_concreto*(2*eps_razao - (eps_razao^2));
                    else
                        tensao_concreto(i) = 0.85*resistencia_concreto;
                    end
                end
            else
                eps_c0 = (2 + 0.005*(resistencia_concreto - 50))*0.001;
                eps_cu = (2.5+2*(1 - resistencia_concreto/100))*0.001;
                for i = 1:numero_camadas_concreto
                    eps_razao(i) = deformacao_concreto(i)/eps_c0;
                    if deformacao_concreto < eps_c0
                        tensao_concreto(i) = 0.85*resistencia_concreto*(1-(1- eps_razao(i))^(2 - 0.008*(resistencia_concreto - 50)));
                    else
                        tensao_concreto(i) = 0.85*resistencia_concreto;
                    end
                end
            end
            
        elseif curva == 2 % ceb_228
            if resistencia_concreto < 50
                eps_c0 = 0.0022;
                eps_cu = 0.0035;
                fcm = resistencia_concreto + 8;
                e_ct = 21500*((resistencia_concreto/10)^0.33);
                A = e_ct*eps_c0/fcm;
                for i = 1:numero_camadas_concreto
                    eps_razao(i) = deformacao_concreto(i)/eps_c0;
                    if abs(deformacao_concreto(i)) <= 0.004
                        tensao_concreto(i) = fcm*(A*eps_razao(i) - eps_razao(i)^2)/(1+(A-2)*eps_razao(i));
                    elseif abs(deformacao_concreto(i)) >0.004
                        eps_razao1 = (0.25*A +0.5)+(0.25*(0.5*A +1)^2 - 0.5)^0.5;
                        ksi = 4*((eps_razao1^2)*(A-2) + 2*eps_razao1 - A)/((eps_razao*(A-2)+1)^2);
                        tensao_concreto(i) = fcm*((ksi/eps_razao1 - 2/(eps_razao1^2))*eps_razao(i)^2 + (4/eps_razao1 - ksi)*eps_razao(i))^-1;
                    end
                end
            end
        end
        if resistencia_concreto > 50
            eps_c0 = (0.7*fcm^0.31)/1000;
            eps_cu = 0.0035;
            eps_razao(i) = deformacao_concreto(i)/eps_c0;
            fcm = resistencia_concreto + 8;
            e_ct = 22000*((resistencia_concreto/10)^0.30);
            A = e_ct*eps_c0/fcm;
            for i = 1:numero_camadas
                if deformacao_concreto(i) <= 0.004
                    tensao_concreto(i) = resistencia_concreto*((A*eps_razao(i)) - eps_razao^2)/(1+(A-2)*eps_razao(i));
                elseif deformacao_concreto(i) >0.004
                    t = (2.45 - 38*resistencia_concreto/1000 + 7.083*resistencia_concreto^2 + 6.574*resistencia_concreto^3/10000000)*1000;
                    ni = (eps_c0 + t)/eps_c0;
                    tensao_concreto(i) = fcm/(1+(eps_razao(i) -1))/((ni -1)^2);
                end
            end
        elseif curva==3;
            for i = 1:numero_camadas_concreto
                if abs(deformacao_concreto(i)) <= 0.002
                    numero(i) = deformacao_concreto(i)/0.002;
                    tensao_concreto(i) = 0.85*resistencia_concreto*(2-numero(i))*numero(i);
                elseif abs(deformacao_concreto(i)) > 0.002 && abs(deformacao_concreto(i)) <=0.0035
                    tensao_concreto(i) = 0.85*resistencia_concreto;
                end
            end
        end
        
        %Curva Aço
        for j = 1:numero_camadas_aco
            if abs(deformacao_aco(j)) < 0.00217
                tensao_aco(j) = 200000*deformacao_aco(j);
            else
                tensao_aco(j) = (deformacao_aco(j)/abs(deformacao_aco(j)))*(resistencia_escoamento_aco + (resistencia_ultima_aco - resistencia_escoamento_aco)*((abs(deformacao_aco(j)) - 0.00217)/(0.05 - abs(deformacao_aco(j)))));
            end
        end
        
        %Modulo Elasticidade
        % Concreto
        for i =1:numero_camadas_concreto
            if abs(deformacao_concreto(i))>0.00000000000000001
                modulo_elasticidade_concreto(i) = tensao_concreto(i)/deformacao_concreto(i);
            elseif deformacao_concreto(i) <= 0
                modulo_elasticidade_concreto(i) = 0;
            end
        end
        for j = 1:numero_camadas_aco
            if abs(deformacao_aco(j)) > 0.000000001
                modulo_elasticidade_aco(j) = tensao_aco(j)/(deformacao_aco(j));
            else
                modulo_elasticidade_aco(j) = 0;
            end
        end
        
        % Cálculo matriz k
        rigidez11_concreto = 0;
        rigidez12_concreto = 0;
        rigidez22_concreto = 0;
        
        for i = 1:numero_camadas_concreto
            if modulo_elasticidade_concreto(i) > 0
                rigidez11_concreto = rigidez11_concreto + modulo_elasticidade_concreto(i)*elem_area_concreto;
                rigidez12_concreto = rigidez12_concreto - modulo_elasticidade_concreto(i)*elem_area_concreto*altura_elemento(i);
                rigidez22_concreto = rigidez22_concreto + modulo_elasticidade_concreto(i)*elem_area_concreto*altura_elemento(i)*altura_elemento(i);
            end
        end
        rigidez11_aco = 0;
        rigidez12_aco = 0;
        rigidez22_aco = 0;
        for i = 1:numero_camadas_aco
            rigidez11_aco = rigidez11_aco + modulo_elasticidade_aco(j)*elem_area_aco(j);
            rigidez12_aco = rigidez12_aco - modulo_elasticidade_aco(j)*elem_area_aco(j)*altura_elemento_aco(j);
            rigidez22_aco = rigidez22_aco + modulo_elasticidade_aco(j)*elem_area_aco(j)*altura_elemento_aco(j)*altura_elemento_aco(j);
        end
        
        rigidez11 = rigidez11_concreto  + rigidez11_aco;
        rigidez12 = rigidez12_concreto  + rigidez12_aco;
        rigidez22 = rigidez22_concreto  + rigidez22_aco;
        
        % Cálculo Momento Fletor e Esforco Normal
        forca_calculada = deformacao_centro_gravidade*rigidez11 + curvatura*rigidez12;
        momento_calculado = -(deformacao_centro_gravidade*rigidez12 + curvatura*rigidez22);
        
        
        % Condição Convergencia
        if forca_calculada - forca_dada < -5
            xmin = xln;
        elseif forca_calculada - forca_dada > 5
            xmax = xln;
        else
            break
        end
    end
    x(k) = -curvatura;
    y(k) = momento_calculado;
end

result = [x ; y]
