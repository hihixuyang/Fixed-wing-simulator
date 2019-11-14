function y = autopilot_(uu,P)
%
% ���˻��Զ���ʻ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��������
NN = 0;
%    pn       = uu(1+NN);  % ���Ա���λ��
%    pe       = uu(2+NN);
h        = uu(3+NN);
Va       = uu(4+NN);  % ����
%    alpha    = uu(5+NN);  % ����
beta     = uu(6+NN);  % �໬��
phi      = uu(7+NN);  % ��ת��
theta    = uu(8+NN);  % ������
chi      = uu(9+NN);  % �����
p        = uu(10+NN); % ��ת�ٶ�
q        = uu(11+NN); % �����ٶ�
r        = uu(12+NN); % ƫ���ٶ�
%    Vg       = uu(13+NN); % �Ե��ٶ�
%    wn       = uu(14+NN); % �������
%    we       = uu(15+NN); % �������
%    psi      = uu(16+NN); % ƫ���ٶ�
%    bx       = uu(17+NN); % x����ƫ��
%    by       = uu(18+NN); % y����ƫ��
%    bz       = uu(19+NN); % z����ƫ��
NN = NN+19;
Va_c     = uu(1+NN);  % ������� (m/s)
h_c      = uu(2+NN);  % ����߶� (m)
chi_c    = uu(3+NN);  % ����߽ǣ�rad��
NN = NN+3;
t        = uu(1+NN);   % ʱ��

autopilot_version = 2;
% �Զ���ʻ�ǰ汾 == 1 <- ���ڵ�г
% �Զ���ʻ�ǰ汾 == 2 <- ���ж���ı�׼�Զ���ʻ��
% �Զ���ʻ�ǰ汾 == 3 <- ����AP������������
switch autopilot_version
    case 1
        [delta, x_command] = autopilot_tuning(Va_c,h_c,chi_c,Va,h,chi,phi,theta,p,q,r,t,P);
    case 2
        [delta, x_command] = autopilot_uavbook(Va_c,h_c,chi_c,Va,h,beta,chi,phi,theta,p,q,r,t,P);
    case 3
        [delta, x_command] = autopilot_TECS(Va_c,h_c,chi_c,Va,h,chi,phi,theta,p,q,r,t,P);
end
y = [delta; x_command];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �Զ���ʻ�ǰ汾
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �Զ����г�������ڵ���ÿ��ѭ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [delta, x_command] = autopilot_tuning(Va_c,h_c,chi_c,Va,h,chi,phi,theta,p,q,r,t,P)

mode = 5;
switch mode
    case 1, % ����������·
        phi_c = chi_c; % ��chi_c����Ϊ�Զ���ʻ�Ǻ���ָ��
        delta_a = roll_hold(phi_c, phi, p, P);
        delta_r = 0; % �޶�
        % �ڵ��������Զ���ʻ��ʱ��ʹ�������������ֵ
        delta_e = P.u_trim(1);
        delta_t = P.u_trim(4);
        theta_c = 0;
    case 2, % ��������ѭ��
        if t==0,
            phi_c   = course_hold(chi_c, chi, r, 1, P);
        else
            phi_c   = course_hold(chi_c, chi, r, 0, P);
        end
        delta_a = roll_hold(phi_c, phi, p, P);
        delta_r = 0;
        % �ڵ��������Զ���ʻ��ʱ��ʹ�������������ֵ
        delta_e = P.u_trim(1);
        delta_t = P.u_trim(4);
        theta_c = 0;
    case 3, % �����ŵ������ٻ�·�͹�ת��·
        theta_c = 20*pi/180 + h_c;
        chi_c = 0;
        if t==0,
            phi_c   = course_hold(chi_c, chi, r, 1, P);
            delta_t = airspeed_with_throttle_hold(Va_c, Va, 1, P);
        else
            phi_c   = course_hold(chi_c, chi, r, 0, P);
            delta_t = airspeed_with_throttle_hold(Va_c, Va, 0, P);
        end
        delta_e = pitch_hold(theta_c, theta, q, P);
        delta_a = roll_hold(phi_c, phi, p, P);
        delta_r = 0;
    case 4, % �������ǵ����ٻ�·
        chi_c = 0;
        delta_t = P.u_trim(4);
        if t==0,
            phi_c   = course_hold(chi_c, chi, r, 1, P);
            theta_c = airspeed_with_pitch_hold(Va_c, Va, 1, P);
        else
            phi_c   = course_hold(chi_c, chi, r, 0, P);
            theta_c = airspeed_with_pitch_hold(Va_c, Va, 0, P);
        end
        delta_a = roll_hold(phi_c, phi, p, P);
        delta_e = pitch_hold(theta_c, theta, q, P);
        delta_r = 0;
    case 5, % �������ǵ��߶Ȼ�·
        chi_c = 0;
        if t==0,
            phi_c   = course_hold(chi_c, chi, r, 1, P);
            theta_c = altitude_hold(h_c, h, 1, P);
            delta_t = airspeed_with_throttle_hold(Va_c, Va, 1, P);
        else
            phi_c   = course_hold(chi_c, chi, r, 0, P);
            theta_c = altitude_hold(h_c, h, 0, P);
            delta_t = airspeed_with_throttle_hold(Va_c, Va, 0, P);
        end
        delta_a = roll_hold(phi_c, phi, p, P);
        delta_e = pitch_hold(theta_c, theta, q, P);
        delta_r = 0;
    case 6, % ���ڸ�����·
        phi_c = 0;
        theta_c = 20*pi/180 + h_c;
        delta_a = P.u_trim(2);
        delta_r = 0;
        
        delta_e = pitch_hold(theta_c, theta, q, P);
        delta_t = P.u_trim(4);
end
%----------------------------------------------------------
% �������

% �������
delta = [delta_e; delta_a; delta_r; delta_t];
% ���ƣ�Ԥ�ڣ�״̬
x_command = [...
    0;...                    % pn
    0;...                    % pe
    h_c;...                  % h
    Va_c;...                 % Va
    0;...                    % alpha
    0;...                    % beta
    phi_c;...                % phi
    theta_c;...              % theta
    chi_c;...                % chi
    0;...                    % p
    0;...                    % q
    0;...                    % r
    ];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ж����Զ���ʻ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [delta, x_command] = autopilot_uavbook(Va_c,h_c,chi_c,Va,h,beta,chi,phi,theta,p,q,r,t,P)

%----------------------------------------------------------
% �����Զ���ʻ��
if t==0
    % ����û�ж棬�������delta_r=0
    delta_r = -sideslip_hold(0, beta, 1, P);
    phi_c   = course_hold(chi_c, chi, r, 1, P);
    delta_a = roll_hold(phi_c, phi, p, 1, P);
else
    delta_r = -sideslip_hold(0, beta, 0, P);
    phi_c   = course_hold(chi_c, chi, r, 0, P);
    delta_a = roll_hold(phi_c, phi, p, 0, P);
end



%----------------------------------------------------------
%�����Զ���ʻ��

% ����߶�״̬��״̬�ĳ־ñ���
persistent altitude_state;
persistent initialize_integrator;
% ��ʼ�����ñ���
if h<=P.altitude_take_off_zone
    altitude_state = 1;      % �������
elseif h<=h_c-P.altitude_hold_zone
    altitude_state = 2;      % ��������
elseif h>=h_c+P.altitude_hold_zone
    altitude_state = 3;      % �½�����
else
    altitude_state = 4;      % �߶ȱ�������
end
if t==0
    initialize_integrator=1;
    % �����ظ���ֵ��Ϊ�˴��� hold ������ĳ�ʼ��
    theta_c = airspeed_with_pitch_hold(Va_c,Va,initialize_integrator,P);
    theta_c = altitude_hold(h_c, h, initialize_integrator, P);
    delta_t = airspeed_with_throttle_hold(Va_c, Va, initialize_integrator, P);
    delta_e = pitch_hold(theta_c, theta, q, initialize_integrator,P);
    initialize_integrator=0;
end

% ��ʾ�߶�״̬
% ʵ��״̬��
switch altitude_state
    case 1  % �������
        theta_c = P.theta_max;
        delta_t = 1;
    case 2  % ��������
        delta_t = 1;
        theta_c = airspeed_with_pitch_hold(Va_c, Va, initialize_integrator, P);
    case 3 % �½�����
        delta_t = 0;
        theta_c = airspeed_with_pitch_hold(Va_c, Va, initialize_integrator, P);
    case 4 % �߶ȱ�������
        delta_t = P.u_trim(4)+airspeed_with_throttle_hold(Va_c, Va, initialize_integrator, P);
        theta_c = altitude_hold(h_c, h, initialize_integrator, P);
end
% ������̬����
delta_e = pitch_hold(theta_c, theta, q, initialize_integrator,P);
% �˹�����delta_t
delta_t = sat(delta_t,1,0);


%----------------------------------------------------------
% �������

% �������
delta = [delta_e; delta_a; delta_r; delta_t];
% ���ƣ�Ԥ�ڣ�״̬
x_command = [...
    0;...                    % pn
    0;...                    % pe
    h_c;...                  % h
    Va_c;...                 % Va
    0;...                    % alpha
    0;...                    % beta
    phi_c;...                % phi
    theta_c; ...             % theta
    chi_c;...                % chi
    0;...                    % p
    0;...                    % q
    0;...                    % r
    ];

% y = [delta; x_command];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �Զ���ʻ��_TECS������������������ϵͳ�������Զ���ʻ��
% ���������ƣ���������Ѳ�����½����������й����ж���������������Ϊ���ָ��Ŀ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [delta, x_command] = autopilot_TECS(Va_c,h_c,chi_c,Va,h,chi,phi,theta,p,q,r,t,P)

%----------------------------------------------------------
% �����Զ���ʻ��
if t==0,
    delta_r = 0;
    phi_c   = course_hold(chi_c, chi, r, 1, P);
    
else
    phi_c   = course_hold(chi_c, chi, r, 0, P);
    delta_r = 0;
end
delta_a = roll_hold(phi_c, phi, p, 0, P);


%----------------------------------------------------------
% �������������Ƶ������Զ���ʻ��


%     theta_c = airspeed_with_pitch_hold(Va_c, Va, flag, P);
theta_c = altitude_hold(h_c, h, flag, 0, P);
delta_e = 0;
delta_t = 0;


%----------------------------------------------------------
% �������

% �������
delta = [delta_e; delta_a; delta_r; delta_t];
% ���ƣ�Ԥ�ڣ�״̬
x_command = [...
    0;...                    % pn
    0;...                    % pe
    h_c;...                  % h
    Va_c;...                 % Va
    0;...                    % alpha
    0;...                    % beta
    phi_c;...                % phi
    theta_c;...              % theta
    chi_c;...                % chi
    0;...                    % p
    0;...                    % q
    0;...                    % r
    ];

y = [delta; x_command];

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �Զ���ʻ�Ǻ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function theta_c = airspeed_with_pitch_hold(Va_c, Va, flag, P)
persistent integrator;
persistent error_d1;
if flag == 1        % reset (initialize) persistent variables when flag==1
    integrator = 0;
    error_d1 = 0;   % _d1 means delayed by one time step
end
error = Va_c - Va;    % compute the current error
integrator = integrator + (P.Ts / 2) * (error + error_d1); % update integrator
error_d1 = error; % update the error for next time through the loop
theta_c = sat(...                   % implement PID control
    P.kp_v2 * error + ...         % proportional term
    P.ki_v2 * integrator, ...    % integral term
    P.pitch_max, -P.pitch_max ... % ensure abs(u)<=limit
    );
if P.ki_v2~=0        % implement integrator anti-windup
    u_unsat = P.kp_v2 * error + P.ki_v2 * integrator;
    integrator = integrator + P.Ts / P.ki_v2 * (theta_c - u_unsat);
end
end

function theta_c = altitude_hold(h_c, h, flag, P)
persistent integrator;
persistent error_d1;
if flag == 1        % reset (initialize) persistent variables when flag==1
    integrator = 0;
    error_d1 = 0;   % _d1 means delayed by one time step
end
error = h_c - h;    % compute the current error
integrator = integrator + (P.Ts / 2) * (error + error_d1); % update integrator
error_d1 = error; % update the error for next time through the loop
theta_c = sat(...                   % implement PID control
    P.kp_h * error + ...         % proportional term
    P.ki_h * integrator, ...    % integral term
    P.pitch_max, -P.pitch_max ...    % ensure abs(u)<=limit
    );
if P.ki_h~=0        % implement integrator anti-windup
    u_unsat = P.kp_h * error + P.ki_h * integrator;
    integrator = integrator + P.Ts / P.ki_h * (theta_c - u_unsat);
end
end

function delta_a = roll_hold(phi_c, phi, p, flag,P)
persistent integrator;
persistent error_d1;
if flag == 1 % reset (initialize) persistent variables when flag==1
    integrator = 0;
    error_d1 = 0;   % _d1 means delayed by one time step
end
error = phi_c - phi;    % compute the current error
integrator = integrator + (P.Ts / 2) * (error + error_d1); % update integrator
error_d1 = error; % update the error for next time through the loop
delta_a = sat(...                   % implement PID controlʵ��PID����
    P.kp_phi * error + ...         % proportional term������
    P.ki_phi * integrator - ...    % integral term������
    P.kd_phi * p,...  % derivative term������
    P.delta_a_max, -P.delta_a_max ... % ensure abs(u)<=limit
    );
if P.ki_phi~=0        % implement integrator anti-windup
    u_unsat = P.kp_phi * error + P.ki_phi * integrator - P.kd_phi * p;
    integrator = integrator + P.Ts / P.ki_phi * (delta_a - u_unsat);
end
end

function phi_c = course_hold(chi_c, chi, r, flag, P)
persistent integrator;
persistent error_d1;
if flag == 1        % reset (initialize) persistent variables when flag==1
    integrator = 0;
    error_d1 = 0;   % _d1 means delayed by one time step
end
error = chi_c - chi;    % compute the current error
integrator = integrator + (P.Ts / 2) * (error + error_d1); % update integrator
error_d1 = error; % update the error for next time through the loop
phi_c = sat(...                   % implement PID control
    P.kp_chi * error + ...         % proportional term
    P.ki_chi * integrator, ...    % integral term
    P.roll_max, -P.roll_max ... % ensure abs(u)<=limit
    );
if P.ki_chi~=0        % implement integrator anti-windup
    u_unsat = P.kp_chi * error + P.ki_chi * integrator;
    integrator = integrator + P.Ts / P.ki_chi * (phi_c - u_unsat);
end
end

function delta_r = sideslip_hold(beta_c, beta, flag, P)
persistent integrator;
persistent error_d1;
if flag == 1        % reset (initialize) persistent variables when flag==1
    integrator = 0;
    error_d1 = 0;   % _d1 means delayed by one time step
end
error = beta_c - beta;    % compute the current error
integrator = integrator + (P.Ts / 2) * (error + error_d1); % update integrator
error_d1 = error; % update the error for next time through the loop
delta_r = sat(...                   % implement PID control
    P.kp_beta * error + ...         % proportional term
    P.ki_beta * integrator, ...    % integral term
    P.delta_r_max, -P.delta_r_max ... % ensure abs(u)<=limit
    );
if P.ki_beta~=0        % implement integrator anti-windup
    u_unsat = P.kp_beta * error + P.ki_beta * integrator;
    integrator = integrator + P.Ts / P.ki_beta * (beta_c - u_unsat);
end
end

function delta_e = pitch_hold(theta_c, theta, q, flag, P)
persistent error_d1;
persistent integrator;
if flag == 1       % reset (initialize) persistent variables when flag==1
    error_d1 = 0;   % _d1 means delayed by one time step
    integrator = 0;
end
error = theta_c - theta;    % compute the current error\
integrator = integrator + (P.Ts / 2) * (error + error_d1);
error_d1 = error; % update the error for next time through the loop
delta_e = sat(...                   % implement PID control
    P.kp_theta * error  ...         % proportional term
    + P.ki_theta * integrator ...
    - P.kd_theta * q,...  % derivative term
    P.delta_e_max, -P.delta_e_max ... % ensure abs(u)<=limit
    );
if P.ki_theta ~= 0        % implement integrator anti-windup
    u_unsat = P.kp_theta * error + P.ki_theta * integrator;
    integrator = integrator + P.Ts / P.ki_theta * (theta_c - u_unsat);
end
end

function delta_t = airspeed_with_throttle_hold(Va_c, Va, flag, P)
persistent integrator;
persistent error_d1;
if flag == 1        % reset (initialize) persistent variables when flag==1
    integrator = 0;
    error_d1 = 0;   % _d1 means delayed by one time step
end
error = Va_c - Va;    % compute the current error
integrator = integrator + (P.Ts / 2) * (error + error_d1); % update integrator
error_d1 = error; % update the error for next time through the loop
delta_t = sat(...                   % implement PID control
    P.kp_v * error + ...         % proportional term
    P.ki_v * integrator, ...    % integral term
    P.delta_t_max, P.delta_t_min ... % ensure abs(u)<=limit
    );
if P.ki_v~=0        % implement integrator anti-windup
    u_unsat = P.kp_v * error + P.ki_v * integrator;
    integrator = integrator + P.Ts / P.ki_v * (delta_t - u_unsat);
end
end

% function theta_c = airspeed_with_pitch_hold(Va_c, Va, flag, P)
%     persistent integrator;
%     persistent error_d1;
%     if isempty(integrator)        % reset (initialize) persistent variables when flag==1
%         integrator = 0;
%         error_d1 = 0;   % _d1 means delayed by one time step
%     end
%     error = Va_c - Va;    % compute the current error
%     integrator = integrator + (P.Ts / 2) * (error + error_d1); % update integrator
%     error_d1 = error; % update the error for next time through the loop
%     theta_c = sat(...                   % implement PID control
%         P.kp_v2 * error + ...         % proportional term
%         P.ki_v2 * integrator, ...    % integral term
%         P.pitch_max, -P.pitch_max ... % ensure abs(u)<=limit
%         );
%     if P.ki_v2~=0        % implement integrator anti-windup
%         u_unsat = P.kp_v2 * error + P.ki_v2 * integrator;
%         integrator = integrator + P.Ts / P.ki_v2 * (theta_c - u_unsat);
%     end
% end
%
% function theta_c = altitude_hold(h_c, h, flag, P)
%     persistent integrator;
%     persistent error_d1;
%     if isempty(integrator)        % reset (initialize) persistent variables when flag==1
%         integrator = 0;
%         error_d1 = 0;   % _d1 means delayed by one time step
%     end
%     error = h_c - h;    % compute the current error
%     integrator = integrator + (P.Ts / 2) * (error + error_d1); % update integrator
%     error_d1 = error; % update the error for next time through the loop
%     theta_c = sat(...                   % implement PID control
%         P.kp_h * error + ...         % proportional term
%         P.ki_h * integrator, ...    % integral term
%         P.pitch_max, -P.pitch_max ...    % ensure abs(u)<=limit
%         );
%     if P.ki_h~=0        % implement integrator anti-windup
%         u_unsat = P.kp_h * error + P.ki_h * integrator;
%         integrator = integrator + P.Ts / P.ki_h * (theta_c - u_unsat);
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sat
%   - saturation function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = sat(in, up_limit, low_limit)
if in > up_limit
    out = up_limit;
elseif in < low_limit
    out = low_limit;
else
    out = in;
end
end
