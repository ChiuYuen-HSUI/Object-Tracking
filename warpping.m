function Iout = warpping(Iin,x,y,M)
    %����任���� (��תRotation, ƽ��Translation, ����Resize)
    %ʵ���Ͼ�����ÿһ֡ͼ�����ҵ������Ŀ��ģ�����ڵ�����

    % ����任�������
    Tlocalx =  M(1,1) * x + M(1,2) *y + M(1,3);   %��������Խǵ�Ϊ���������ģ���T��Χ֮�ڵ�x,y��ͼ���rows,cols��ϵ����
    Tlocaly =  M(2,1) * x + M(2,2) *y + M(2,3);
    %Iout  = interp2(Iin, Tlocalx, Tlocaly,'*linear');
    % ���е��������ض��漰�����Բ�ֵ.
    xBas0=floor(Tlocalx);      %��������ǰһλ����ȡ��
    yBas0=floor(Tlocaly);
    xBas1=xBas0+1;             %���������һλ����ȡ��
    yBas1=yBas0+1;

    % ���Բ�ֵ����(�ٷֱ�)
    xCom=Tlocalx-xBas0;
    yCom=Tlocaly-yBas0;
    perc0=(1-xCom).*(1-yCom);
    perc1=(1-xCom).*yCom;
    perc2=xCom.*(1-yCom);
    perc3=xCom.*yCom;

    % ���������Ƶ��߽�
    check_xBas0=(xBas0<0)|(xBas0>(size(Iin,1)-1));    %�ȶ����ڵķ�Χ���ж�
    check_yBas0=(yBas0<0)|(yBas0>(size(Iin,2)-1));
    xBas0(check_xBas0)=0;                 %�������ͼ��Ĵ�С��ΧΪ�����Ϊ0
    yBas0(check_yBas0)=0;
    check_xBas1=(xBas1<0)|(xBas1>(size(Iin,1)-1));
    check_yBas1=(yBas1<0)|(yBas1>(size(Iin,2)-1));
    xBas1(check_xBas1)=0;
    yBas1(check_yBas1)=0;

    Iout=zeros([size(x) size(Iin,3)]);
    for i=1:size(Iin,3);
        Iin_one=Iin(:,:,i);
        % Get the intensities
        intensity_xyz0=Iin_one(1+xBas0+yBas0*size(Iin,1));
        intensity_xyz1=Iin_one(1+xBas0+yBas1*size(Iin,1));
        intensity_xyz2=Iin_one(1+xBas1+yBas0*size(Iin,1));
        intensity_xyz3=Iin_one(1+xBas1+yBas1*size(Iin,1));
        Iout_one=intensity_xyz0.*perc0+intensity_xyz1.*perc1+intensity_xyz2.*perc2+intensity_xyz3.*perc3;
        Iout(:,:,i)=reshape(Iout_one, [size(x,1) size(x,2)]);
    end
end


