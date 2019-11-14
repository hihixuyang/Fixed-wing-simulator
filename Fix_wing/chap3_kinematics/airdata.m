function out=airdata(uu)
%
% Fake air data - this will be replaced with real air data in Chapter 4
%
% modified 12/11/2009 - RB

    % process inputs to function
 % ״̬����
    pn          = uu(1);             % ���Ա���λ�� ���ף�
    pe          = uu(2);             % ���Զ���λ�� (��)
    h           = -uu(3);            % �߶� (�ף�����Ե���λ���෴)
    u           = uu(4);             % ����x���ٶ� (��/��)
    v           = uu(5);             % ����y���ٶ� (��/��)
    w           = uu(6);             % ����z���ٶ�(��/��)
    phi         = 180/pi*uu(7);      % ��ת�� (��)   
    theta       = 180/pi*uu(8);      % ������(��)
    psi         = 180/pi*uu(9);      % ƫ���� (��)
    p           = 180/pi*uu(10);     % ����x���ת�ٶ� (��/��)
    q           = 180/pi*uu(11);     % ����y�ḩ���ٶ� (��/��)
    r           = 180/pi*uu(12);     % ����z��ƫ���ٶ� (��/��)

    Va = sqrt(u^2+v^2+w^2);%����
    alpha = atan2(w,u);%���������ʸ���нǣ�����
    beta  = asin(v);%�ٶ�ʸ�������i-kƽ��нǣ��໬��
    wn    = 0;%��ı������
    we    = 0;%��Ķ������
    wd    = 0;%��ĵ������
    
    out = [Va; alpha; beta; wn; we; wd];
    