function [sys,x0,str,ts,simStateCompliance] = mav_dynamics(t,x,u,flag,P)
%t��ǰʱ�䣬x״̬������uģ�����룬flag�����־��Pģ�����
%sys�Ӻ�������ֵ��ȡ����flag����x0����״̬�ĳ�ʼ��������flag=0����str�վ���ts����ʱ�䣬simStateCompliance����״̬
%mdlInitializeSizes��ʼ��ģ��������flag=0��
%mdlDerivatives��������״̬������flag=1��
%mdlUpdate������ɢ״̬������ʱ�䡢���ʱ�䲽��flag=2��
%mdlOutputs����s-���������flag=3��
%mdlGetTimeOfNextVarHit������һ������ʱ�䣨flag=4��
%mdlTerminate��ֹ���棨flag=9��
switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(P);

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1
    sys=mdlDerivatives(t,x,u,P);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(P)

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 12;%����״̬����
sizes.NumDiscStates  = 0;%��ɢ״̬����
sizes.NumOutputs     = 12;%�������
sizes.NumInputs      = 6;%�������
sizes.DirFeedthrough = 0;%�Ƿ�ֱ����ͨ
sizes.NumSampleTimes = 1;%����ʱ�����������һ��

sys = simsizes(sizes);%��size�ṹ����sys��

%
% initialize the initial conditions
%��ʼ״̬�������ɴ������������û��Ϊ��
x0  = [...
    P.pn0;...
    P.pe0;...
    P.pd0;...
    P.u0;...
    P.v0;...
    P.w0;...
    P.phi0;...
    P.theta0;...
    P.psi0;...
    P.p0;...
    P.q0;...
    P.r0;...
    ];

%
% str is always an empty matrix
%
str = [];
%str�վ���
% initialize the array of sample times
%
ts  = [0 0];%���ò���ʱ�䣬����������������ƫ����Ϊ0

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,uu, P)%mdlDerivatives��������״̬������flag=1��

    pn    = x(1);
    pe    = x(2);
    pe    = x(3);
    u     = x(4);
    v     = x(5);
    w     = x(6);
    phi   = x(7);
    theta = x(8);
    psi   = x(9);
    p     = x(10);
    q     = x(11);
    r     = x(12);
    fx    = uu(1);
    fy    = uu(2);
    fz    = uu(3);
    ell   = uu(4);
    m     = uu(5);
    n     = uu(6);
    sp = sin(phi);
    cp = cos(phi);
    st = sin(theta);
    ct = cos(theta);
    ss = sin(psi);
    cs = cos(psi);
    tt = tan(theta);
    
    % ƽ���˶�ѧ
    rotation_position = [ct*cs sp*st*cs-cp*ss cp*st*cs+sp*ss;
                         ct*ss sp*st*ss+cp*cs cp*st*ss-sp*cs;
                         -st sp*ct cp*ct
                         ];
    position_dot = rotation_position*[u; v; w];
    pndot = position_dot(1);
    pedot = position_dot(2);
    pddot = position_dot(3);
    
    % ƽ�ƶ���ѧ
    udot = r*v-q*w+fx/P.mass;
    vdot = p*w-r*u+fy/P.mass;
    wdot = q*u-p*v+fz/P.mass;
    
    % ��ת�˶�ѧ
    rotation_angle = [1 sp*tt cp*tt;
                      0 cp -sp;
                      0 sp/ct cp/ct
                      ];
    angle_dot = rotation_angle*[p; q; r];
    phidot = angle_dot(1);
    thetadot = angle_dot(2);
    psidot = angle_dot(3);
    
    % Gamma1 - Gamma8
    Gamma = P.Jx*P.Jz-P.Jxz^2;
    Gamma1 = P.Jxz*(P.Jx-P.Jy+P.Jz)/Gamma;
    Gamma2 = (P.Jz*(P.Jz-P.Jy)+P.Jxz^2)/Gamma;
    Gamma3 = P.Jz/Gamma;
    Gamma4 = P.Jxz/Gamma;
    Gamma5 = (P.Jz-P.Jx)/P.Jy;
    Gamma6 = P.Jxz/P.Jy;
    Gamma7 = ((P.Jx-P.Jy)*P.Jx+P.Jxz^2)/Gamma;
    Gamma8 = P.Jx/Gamma;
    
    % ת������ѧ
    pdot = Gamma1*p*q-Gamma2*q*r+Gamma3*ell+Gamma4*n;
    qdot = Gamma5*p*r-Gamma6*(p^2-r^2)+m/P.Jy;
    rdot = Gamma7*p*q-Gamma1*q*r+Gamma4*ell+Gamma8*n;

sys = [pndot; pedot; pddot; udot; vdot; wdot; phidot; thetadot; psidot; pdot; qdot; rdot];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)%mdlUpdate������ɢ״̬������ʱ�䡢���ʱ�䲽��flag=2��

sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)%mdlOutputs����s-���������flag=3��


sys = x;

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)%mdlGetTimeOfNextVarHit������һ������ʱ�䣨flag=4��

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)%mdlTerminate��ֹ���棨flag=9��

sys = [];

% end mdlTerminate
