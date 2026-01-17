classdef RocketTATGbyAliAerospace < matlab.apps.AppBase
    %PROPERTY OF AliAerospace GitHub

    properties (Access = public)
        UIFigure    matlab.ui.Figure
        TabGroup    matlab.ui.container.TabGroup
        InputsTab   matlab.ui.container.Tab
        OutputsTab  matlab.ui.container.Tab
        VisualTab   matlab.ui.container.Tab
        RunButton   matlab.ui.control.Button

        StatorAerofoilAxes matlab.ui.control.UIAxes
        RotorAerofoilAxes  matlab.ui.control.UIAxes
        %panels
        GasInletPanel
        DesignPanel
        Stage1Panel
        Stage2Panel
        GeometryPanel
        NacaStatorPanel
        NacaRotorPanel

        %outputs
        OutputsTable
        StatusArea

        %visual
        VisualAxes

        %fields
        GammaEdit  matlab.ui.control.EditField
        CpEdit     matlab.ui.control.EditField
        Tt4Edit    matlab.ui.control.EditField
        Pt4Edit    matlab.ui.control.EditField
        MdotEdit   matlab.ui.control.EditField
        NozzleLossCoeffEdit matlab.ui.control.EditField

        PshaftEdit matlab.ui.control.EditField
        EtaMEdit   matlab.ui.control.EditField
        EtaTEdit   matlab.ui.control.EditField
        NEdit      matlab.ui.control.EditField
        RmEdit     matlab.ui.control.EditField
        PhiEdit    matlab.ui.control.EditField

        Tsplit1Edit matlab.ui.control.EditField
        Lambda1Edit matlab.ui.control.EditField
        Tsplit2Edit matlab.ui.control.EditField
        Lambda2Edit matlab.ui.control.EditField

        Stage1StatorBladeCountEdit matlab.ui.control.EditField
        Stage1RotorBladeCountEdit  matlab.ui.control.EditField
        Stage2StatorBladeCountEdit matlab.ui.control.EditField
        Stage2RotorBladeCountEdit  matlab.ui.control.EditField
        StatorChordEdit            matlab.ui.control.EditField
        RotorChordEdit             matlab.ui.control.EditField
        AxialGapEdit               matlab.ui.control.EditField
        HubTipRatioParamEdit       matlab.ui.control.EditField

        %aerofoil fields
        NacaSmEdit matlab.ui.control.EditField
        NacaSpEdit matlab.ui.control.EditField
        NacaStEdit matlab.ui.control.EditField

        NacaRmEdit matlab.ui.control.EditField
        NacaRpEdit matlab.ui.control.EditField
        NacaRtEdit matlab.ui.control.EditField
    end

    methods (Access = private)

        function createComponents(app)
            %turbine figure
            app.UIFigure = uifigure('Name',['Rocket Turbopump Axial Turbine Generation (Rocket-TATG) by AliAerospace']);
            app.UIFigure.Position = [100 100 1250 720];
            app.UIFigure.SizeChangedFcn = @(~,~)centerRunButton(app);

            %tabs
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 1250 720];
            app.InputsTab  = uitab(app.TabGroup,'Title','Inputs');
            app.OutputsTab = uitab(app.TabGroup,'Title','Outputs');
            app.VisualTab  = uitab(app.TabGroup,'Title','Visual');

            %run
            app.RunButton = uibutton(app.UIFigure,'push', ...
                'Text','Run', ...
                'ButtonPushedFcn', @(~,~)runButtonPushed(app));
            centerRunButton(app);

            %input in grids
            app.GasInletPanel = uipanel(app.InputsTab,'Title','Gas and Inlet', ...
                'Position',[20 420 600 270]);
            g1 = uigridlayout(app.GasInletPanel,[6 2]);
            g1.RowHeight = repmat({32},1,6);
            g1.ColumnWidth = {300,'1x'};
            g1.Padding = [12 12 12 12];
            g1.RowSpacing = 8; g1.ColumnSpacing = 10;

            app.GammaEdit = mkRow(g1,1,'$\gamma_g$  (specific heat ratio) [-]', true);
            app.CpEdit    = mkRow(g1,2,'$C_{Pg}$  (gas specific heat) [J/(kg$\cdot$K)]', true);
            app.Tt4Edit   = mkRow(g1,3,'$T$  (turbine inlet total temperature) [K]', true);
            app.Pt4Edit   = mkRow(g1,4,'$P$  (turbine inlet total pressure) [Pa]', true);
            app.MdotEdit  = mkRow(g1,5,'$\dot{m}_g$  (gas mass flow rate) [kg/s]', true);
            app.NozzleLossCoeffEdit = mkRow(g1,6,'$\lambda_n$ Nozzle loss coefficient [-]', true);

            app.DesignPanel = uipanel(app.InputsTab,'Title','Power, Efficiencies and Parameters', ...
                'Position',[640 420 590 270]);
            g2 = uigridlayout(app.DesignPanel,[6 2]);
            g2.RowHeight = repmat({32},1,6);
            g2.ColumnWidth = {330,'1x'};
            g2.Padding = [12 12 12 12];
            g2.RowSpacing = 8; g2.ColumnSpacing = 10;

            app.PshaftEdit = mkRow(g2,1,'Shaft power required [W]', false);
            app.EtaMEdit   = mkRow(g2,2,'$\eta_m$  (mechanical efficiency) [-]', true);
            app.EtaTEdit   = mkRow(g2,3,'$\eta_s$  (isentropic efficiency) [-]', true);
            app.NEdit      = mkRow(g2,4,'Rotational speed (rev/s)', false);
            app.RmEdit     = mkRow(g2,5,'Mean radius [m]', false);
            app.PhiEdit    = mkRow(g2,6,'$\phi$  (flow coefficient) [-]', true);

            app.Stage1Panel = uipanel(app.InputsTab,'Title','Stage 1 Parameters', ...
                'Position',[20 250 600 150]);
            g3 = uigridlayout(app.Stage1Panel,[2 2]);
            g3.RowHeight = {32,32}; g3.ColumnWidth = {330,'1x'};
            g3.Padding = [12 12 12 12];
            g3.RowSpacing = 8; g3.ColumnSpacing = 10;
            app.Tsplit1Edit = mkRow(g3,1,'Temperature drop (stage 1) [-]', false);
            app.Lambda1Edit = mkRow(g3,2,'$\Lambda_1$  (reaction) [-]', true);

            app.Stage2Panel = uipanel(app.InputsTab,'Title','Stage 2 Parameters', ...
                'Position',[640 250 590 150]);
            g4 = uigridlayout(app.Stage2Panel,[2 2]);
            g4.RowHeight = {32,32}; g4.ColumnWidth = {330,'1x'};
            g4.Padding = [12 12 12 12];
            g4.RowSpacing = 8; g4.ColumnSpacing = 10;
            app.Tsplit2Edit = mkRow(g4,1,'Temperature drop (stage 2) [-]', false);
            app.Lambda2Edit = mkRow(g4,2,'$\Lambda_2$  (reaction) [-]', true);

            app.GeometryPanel = uipanel(app.InputsTab,'Title','Geometry Controls', ...
                'Position',[20 -70 600 300]);
            g5 = uigridlayout(app.GeometryPanel,[8 2]);
            g5.RowHeight = repmat({26},1,8);
            g5.ColumnWidth = {330,'1x'};
            g5.Padding = [12 12 12 12];
            g5.RowSpacing = 6; g5.ColumnSpacing = 10;

            app.Stage1StatorBladeCountEdit = mkRow(g5,1,'Stage 1 stator blade count [-]', false);
            app.Stage1RotorBladeCountEdit  = mkRow(g5,2,'Stage 1 rotor blade count [-]', false);
            app.Stage2StatorBladeCountEdit = mkRow(g5,3,'Stage 2 stator blade count [-]', false);
            app.Stage2RotorBladeCountEdit  = mkRow(g5,4,'Stage 2 rotor blade count [-]', false);
            app.StatorChordEdit            = mkRow(g5,5,'Stator chord [m]', false);
            app.RotorChordEdit             = mkRow(g5,6,'Rotor chord [m]', false);
            app.AxialGapEdit               = mkRow(g5,7,'Axial gap between rows [m]', false);
            app.HubTipRatioParamEdit       = mkRow(g5,8,'Blade hub–tip ratio [-]', false);

            %aerofoil panels
            app.NacaStatorPanel = uipanel(app.InputsTab,'Title','Blade Parameters (Stators)', ...
                'Position',[640 130 590 100]);
            g6 = uigridlayout(app.NacaStatorPanel,[1 6]);
            g6.ColumnWidth = {120,90, 120,90, 120,90};
            g6.RowHeight = {36};
            g6.Padding = [12 12 12 12];
            g6.ColumnSpacing = 10;

            mkLabel(g6,1,'Camber m [-]', false);      app.NacaSmEdit = mkEdit(g6,2);
            mkLabel(g6,3,'Location p [-]', false);    app.NacaSpEdit = mkEdit(g6,4);
            mkLabel(g6,5,'Thickness t [-]', false);   app.NacaStEdit = mkEdit(g6,6);

            app.NacaRotorPanel = uipanel(app.InputsTab,'Title','Blade Parameters (Rotors)', ...
                'Position',[640 20 590 100]);
            g7 = uigridlayout(app.NacaRotorPanel,[1 6]);
            g7.ColumnWidth = {120,90, 120,90, 120,90};
            g7.RowHeight = {36};
            g7.Padding = [12 12 12 12];
            g7.ColumnSpacing = 10;

            mkLabel(g7,1,'Camber m [-]', false);      app.NacaRmEdit = mkEdit(g7,2);
            mkLabel(g7,3,'Location p [-]', false);    app.NacaRpEdit = mkEdit(g7,4);
            mkLabel(g7,5,'Thickness t [-]', false);   app.NacaRtEdit = mkEdit(g7,6);

            %gas and inlet default
            app.GammaEdit.Value = '1.333';
            app.CpEdit.Value    = '7662';
            app.Tt4Edit.Value   = '700';
            app.Pt4Edit.Value   = '4e6';
            app.MdotEdit.Value  = '300.0';
            app.NozzleLossCoeffEdit.Value = '0.05';

            %power efficiencies defaults
            app.PshaftEdit.Value = '3.58e7';
            app.EtaMEdit.Value   = '0.95';
            app.EtaTEdit.Value   = '0.825';
            app.NEdit.Value      = '668';
            app.RmEdit.Value     = '0.122';
            app.PhiEdit.Value    = '0.5';

            %reaction and temp defaults
            app.Tsplit1Edit.Value = '0.55';
            app.Lambda1Edit.Value = '0.5';
            app.Tsplit2Edit.Value = '0.45';
            app.Lambda2Edit.Value = '0.5';
          

            %geometry control defaults
            app.Stage1StatorBladeCountEdit.Value = '41';
            app.Stage1RotorBladeCountEdit.Value  = '31';
            app.Stage2StatorBladeCountEdit.Value = '39';
            app.Stage2RotorBladeCountEdit.Value  = '29';
            app.StatorChordEdit.Value            = '0.035';
            app.RotorChordEdit.Value             = '0.030';
            app.AxialGapEdit.Value               = '0.010';
            app.HubTipRatioParamEdit.Value       = '0.7';

            %stator defaults
            app.NacaSmEdit.Value = '0.00';
            app.NacaSpEdit.Value = '0.40';
            app.NacaStEdit.Value = '0.10';

            %rotor default
            app.NacaRmEdit.Value = '0.00';
            app.NacaRpEdit.Value = '0.40';
            app.NacaRtEdit.Value = '0.12';

            app.StatorAerofoilAxes = uiaxes(app.InputsTab,'Position',[20 -80 580 120]);
            title(app.StatorAerofoilAxes,'Stator aerofoil'); grid(app.StatorAerofoilAxes,'on'); axis(app.StatorAerofoilAxes,'equal');

            app.RotorAerofoilAxes  = uiaxes(app.InputsTab,'Position',[650 -80 580 120]);
            title(app.RotorAerofoilAxes,'Rotor aerofoil');  grid(app.RotorAerofoilAxes,'on'); axis(app.RotorAerofoilAxes,'equal');

            %tab of outputs
            outPanel = uipanel(app.OutputsTab,'Title','Computed Outputs', ...
                'Position',[20 20 1210 670]);

            app.OutputsTable = uitable(outPanel, ...
                'Position',[20 20 1170 630], ...
                'ColumnName', {'Variable','Value','Units'}, ...
                'ColumnEditable',[false false false]);

            %visual tab
            app.VisualAxes = uiaxes(app.VisualTab,'Position',[20 20 1210 670]);
            title(app.VisualAxes,'Turbine Blades All Stages');
            grid(app.VisualAxes,'on');
            view(app.VisualAxes,3);
        end

        function centerRunButton(app)

            app.RunButton.Position = [970 -25 180 36];
            app.RunButton.Parent = app.InputsTab;
        end

        function R = solveTurbine(app)
            %meanline solver (if you wish to access the raw code just message me)
            gamma_g = str2double(app.GammaEdit.Value);
            C_Pg    = str2double(app.CpEdit.Value);
            Tt4     = str2double(app.Tt4Edit.Value);
            Pt4     = str2double(app.Pt4Edit.Value);
            mdotg   = str2double(app.MdotEdit.Value);
            lambdaN = str2double(app.NozzleLossCoeffEdit.Value);

            %power and efficiencies
            Pshaft  = str2double(app.PshaftEdit.Value);
            eta_m   = str2double(app.EtaMEdit.Value);
            eta_t   = str2double(app.EtaTEdit.Value);
            %speed and mean radius
            N       = str2double(app.NEdit.Value);
            r_m     = str2double(app.RmEdit.Value);
            %flow coefficient at mean line
            phi     = str2double(app.PhiEdit.Value);

            Tsplit1 = str2double(app.Tsplit1Edit.Value);
            Lambda1 = str2double(app.Lambda1Edit.Value);
            Tsplit2 = str2double(app.Tsplit2Edit.Value);
            Lambda2 = str2double(app.Lambda2Edit.Value);

            NbS1 = str2double(app.Stage1StatorBladeCountEdit.Value);
            NbR1 = str2double(app.Stage1RotorBladeCountEdit.Value);
            NbS2 = str2double(app.Stage2StatorBladeCountEdit.Value);
            NbR2 = str2double(app.Stage2RotorBladeCountEdit.Value);

            cS  = str2double(app.StatorChordEdit.Value);
            cR  = str2double(app.RotorChordEdit.Value);
            gap = str2double(app.AxialGapEdit.Value);
            k_h = str2double(app.HubTipRatioParamEdit.Value);

            R_g = C_Pg*(gamma_g-1)/gamma_g;

            %if you are reading this then my respect for you has went up
            %higher than the temperature of the turbine inlet!. 
            % 
            % 
            %I had fun building the velocity triangles for this code and if you have
            %questions regarding it or would like to see some of my
            %handwritten work, then please contact me! I would love to talk.

            %I also assume you are either sizing your own turbine or are
            %inspired to make your own program... good luck with it - Ali

            U  = 2*pi*r_m*N;
            Ca = phi*U;

            %required total enthalpy and totalT drop across turbine
            dh0_tot = Pshaft/(eta_m*mdotg);
            dT0_tot = dh0_tot/C_Pg;

            %split total drop into two stages
            dT0_1 = Tsplit1*dT0_tot;
            dT0_2 = Tsplit2*dT0_tot;

            psi1 = (2*C_Pg*dT0_1)/(U^2);
            psi2 = (2*C_Pg*dT0_2)/(U^2);
            %stage 1 angles
            tanbeta3_1 = (0.5*psi1 + 2*Lambda1)/(2*phi);
            tanbeta2_1 = (0.5*psi1 - 2*Lambda1)/(2*phi);
            beta3_1  = atan(tanbeta3_1);
            beta2_1  = atan(tanbeta2_1);
            alpha3_1 = atan(tanbeta3_1 - 1/phi);
            alpha2_1 = atan(tanbeta2_1 + 1/phi);
            %stage 2 angles
            tanbeta3_2 = (0.5*psi2 + 2*Lambda2)/(2*phi);
            tanbeta2_2 = (0.5*psi2 - 2*Lambda2)/(2*phi);
            beta3_2  = atan(tanbeta3_2);
            beta2_2  = atan(tanbeta2_2);
            alpha3_2 = atan(tanbeta3_2 - 1/phi);
            alpha2_2 = atan(tanbeta2_2 + 1/phi);

            Tstar_Tt = 2/(gamma_g+1);
            Pstar_Pt = (2/(gamma_g+1))^(gamma_g/(gamma_g-1));

            Tt01_1  = Tt4;  Pt01_1 = Pt4;
            Tt03_1  = Tt01_1 - dT0_1;
            Tt03s_1 = Tt01_1 - dT0_1/eta_t;
            Pt03_1  = Pt01_1*(Tt03s_1/Tt01_1)^(gamma_g/(gamma_g-1));

            %choke check 1
            C2_1  = Ca/cos(alpha2_1);  Ca2_1 = Ca;
            T2_1  = Tt01_1 - C2_1^2/(2*C_Pg);
            T2s_1 = T2_1 - lambdaN*(C2_1^2/(2*C_Pg));
            P2_1  = Pt01_1*(T2s_1/Tt01_1)^(gamma_g/(gamma_g-1));
            P2crit_1 = Pt01_1*Pstar_Pt;
            chokeS1 = (P2_1 < P2crit_1);
            if chokeS1
                P2_1 = P2crit_1;
                T2_1 = Tt01_1*Tstar_Tt;
                C2_1 = sqrt(gamma_g*R_g*T2_1);
                Ca2_1 = C2_1*cos(alpha2_1);
            end
            rho2_1 = P2_1/(R_g*T2_1);
            A2_1   = mdotg/(rho2_1*Ca2_1);
            h2_1   = A2_1/(2*pi*r_m);

            C3_1  = Ca/cos(alpha3_1);  Ca3_1 = Ca;
            T3_1  = Tt03_1 - C3_1^2/(2*C_Pg);
            P3_1  = Pt03_1*(T3_1/Tt03_1)^(gamma_g/(gamma_g-1));
            rho3_1 = P3_1/(R_g*T3_1);
            A3_1   = mdotg/(rho3_1*Ca3_1);
            h3_1   = A3_1/(2*pi*r_m);

            Tt01_2  = Tt03_1;  Pt01_2 = Pt03_1;
            Tt03_2  = Tt01_2 - dT0_2;
            Tt03s_2 = Tt01_2 - dT0_2/eta_t;
            Pt03_2  = Pt01_2*(Tt03s_2/Tt01_2)^(gamma_g/(gamma_g-1));

            %choke check 2
            C2_2  = Ca/cos(alpha2_2);  Ca2_2 = Ca;
            T2_2  = Tt01_2 - C2_2^2/(2*C_Pg);
            T2s_2 = T2_2 - lambdaN*(C2_2^2/(2*C_Pg));
            P2_2  = Pt01_2*(T2s_2/Tt01_2)^(gamma_g/(gamma_g-1));
            P2crit_2 = Pt01_2*Pstar_Pt;
            chokeS2 = (P2_2 < P2crit_2);
            if chokeS2
                P2_2 = P2crit_2;
                T2_2 = Tt01_2*Tstar_Tt;
                C2_2 = sqrt(gamma_g*R_g*T2_2);
                Ca2_2 = C2_2*cos(alpha2_2);
            end
            rho2_2 = P2_2/(R_g*T2_2);
            A2_2   = mdotg/(rho2_2*Ca2_2);
            h2_2   = A2_2/(2*pi*r_m);

            C3_2  = Ca/cos(alpha3_2);  Ca3_2 = Ca;
            T3_2  = Tt03_2 - C3_2^2/(2*C_Pg);
            P3_2  = Pt03_2*(T3_2/Tt03_2)^(gamma_g/(gamma_g-1));
            rho3_2 = P3_2/(R_g*T3_2);
            A3_2   = mdotg/(rho3_2*Ca3_2);
            h3_2   = A3_2/(2*pi*r_m);

            rtip = 2*r_m/(1+k_h);
            rhub = k_h*rtip;

            R = struct;
            R.gamma_g=gamma_g; R.C_Pg=C_Pg; R.Tt4=Tt4; R.Pt4=Pt4; R.mdotg=mdotg;
            R.Pshaft=Pshaft; R.eta_m=eta_m; R.eta_t=eta_t; R.N=N; R.r_m=r_m; R.phi=phi;
            R.Tsplit1=Tsplit1; R.Tsplit2=Tsplit2; R.Lambda1=Lambda1; R.Lambda2=Lambda2;
            R.lambdaN = lambdaN;

            R.R_g=R_g; R.U=U; R.Ca=Ca; R.dh0_tot=dh0_tot; R.dT0_tot=dT0_tot;
            R.dT0_1=dT0_1; R.dT0_2=dT0_2; R.psi1=psi1; R.psi2=psi2;

            R.alpha2_1=alpha2_1; R.alpha3_1=alpha3_1; R.beta2_1=beta2_1; R.beta3_1=beta3_1;
            R.alpha2_2=alpha2_2; R.alpha3_2=alpha3_2; R.beta2_2=beta2_2; R.beta3_2=beta3_2;

            R.Tt01_1=Tt01_1; R.Pt01_1=Pt01_1; R.Tt03_1=Tt03_1; R.Pt03_1=Pt03_1;
            R.Tt01_2=Tt01_2; R.Pt01_2=Pt01_2; R.Tt03_2=Tt03_2; R.Pt03_2=Pt03_2;

            R.A2_1=A2_1; R.h2_1=h2_1; R.A3_1=A3_1; R.h3_1=h3_1;
            R.A2_2=A2_2; R.h2_2=h2_2; R.A3_2=A3_2; R.h3_2=h3_2;

            R.chokeS1=chokeS1; R.chokeS2=chokeS2;

            R.rhub=rhub; R.rtip=rtip;
            R.NbS1=NbS1; R.NbR1=NbR1; R.NbS2=NbS2; R.NbR2=NbR2;
            R.cS=cS; R.cR=cR; R.gap=gap;
            R.a2_1=rad2deg(alpha2_1); R.a3_1=rad2deg(alpha3_1); R.b2_1=rad2deg(beta2_1); R.b3_1=rad2deg(beta3_1);
            R.a2_2=rad2deg(alpha2_2); R.a3_2=rad2deg(alpha3_2); R.b2_2=rad2deg(beta2_2); R.b3_2=rad2deg(beta3_2);
        end

        function runButtonPushed(app)
            R = solveTurbine(app); fmt = @(x) sprintf('%.6g', x); Tt3_ideal = R.Tt4 - R.dT0_tot;
            app.OutputsTable.Data = {
                'gas constant (R_g)', fmt(R.R_g), 'J/(kg*K)'
                'mean blade speed (U)', fmt(R.U), 'm/s'
                'axial velocity (C_a)', fmt(R.Ca), 'm/s'
                'total turbine enthalpy drop (dh0_tot)', fmt(R.dh0_tot), 'J/kg'
                'total turbine temperature drop (dT0_tot)', fmt(R.dT0_tot), 'K'
                'ideal turbine exit total temperature (Tt3_ideal)', fmt(Tt3_ideal), 'K'
                'nozzle loss coefficient (lambdaN)', fmt(R.lambdaN), '-'
                'stage 1 total temperature drop (dT0_1)', fmt(R.dT0_1), 'K'
                'stage 1 loading coefficient (psi1)', fmt(R.psi1), '-'
                'stage 1 reaction (Lambda1)', fmt(R.Lambda1), '-'
                'stage 1 stator exit absolute flow angle (alpha2_1)', fmt(R.a2_1), 'deg'
                'stage 1 rotor exit absolute flow angle (alpha3_1)', fmt(R.a3_1), 'deg'
                'stage 1 rotor inlet relative flow angle (beta2_1)', fmt(R.b2_1), 'deg'
                'stage 1 rotor exit relative flow angle (beta3_1)', fmt(R.b3_1), 'deg'
                'stage 1 inlet total temperature (Tt01_1)', fmt(R.Tt01_1), 'K'
                'stage 1 inlet total pressure (Pt01_1)', fmt(R.Pt01_1), 'Pa'
                'stage 1 exit total temperature (Tt03_1)', fmt(R.Tt03_1), 'K'
                'stage 1 exit total pressure (Pt03_1)', fmt(R.Pt03_1), 'Pa'
                'stage 1 stator choked flag', fmt(double(R.chokeS1)), '0/1'
                'exit of stage 1 stator flow area (A2_1)', fmt(R.A2_1), 'm^2'
                'exit of stage 1 stator blade height (h2_1)', fmt(R.h2_1), 'm'
                'exit of stage 1 rotor flow area (A3_1)', fmt(R.A3_1), 'm^2'
                'exit of stage 1 rotor blade height (h3_1)', fmt(R.h3_1), 'm'
                'stage 2 total temperature drop (dT0_2)', fmt(R.dT0_2), 'K'
                'stage 2 loading coefficient (psi2)', fmt(R.psi2), '-'
                'stage 2 reaction (Lambda2)', fmt(R.Lambda2), '-'
                'stage 2 stator exit absolute flow angle (alpha2_2)', fmt(R.a2_2), 'deg'
                'stage 2 rotor exit absolute flow angle (alpha3_2)', fmt(R.a3_2), 'deg'
                'stage 2 rotor inlet relative flow angle (beta2_2)', fmt(R.b2_2), 'deg'
                'stage 2 rotor exit relative flow angle (beta3_2)', fmt(R.b3_2), 'deg'
                'stage 2 inlet total temperature (Tt01_2)', fmt(R.Tt01_2), 'K'
                'stage 2 inlet total pressure (Pt01_2)', fmt(R.Pt01_2), 'Pa'
                'stage 2 exit total temperature (Tt03_2)', fmt(R.Tt03_2), 'K'
                'stage 2 exit total pressure (Pt03_2)', fmt(R.Pt03_2), 'Pa'
                'stage 2 stator choked flag', fmt(double(R.chokeS2)), '0/1'
                'exit of stage 2 stator flow area (A2_2)', fmt(R.A2_2), 'm^2'
                'exit of stage 2 stator blade height (h2_2)', fmt(R.h2_2), 'm'
                'exit of stage 2 rotor flow area (A3_2)', fmt(R.A3_2), 'm^2'
                'exit of stage 2 rotor blade height (h3_2)', fmt(R.h3_2), 'm'
                'hub radius (rhub)', fmt(R.rhub), 'm'
                'tip radius (rtip)', fmt(R.rtip), 'm'
                'stator chord (cS)', fmt(R.cS), 'm'
                'rotor chord (cR)', fmt(R.cR), 'm'
                'axial gap between rows (gap)', fmt(R.gap), 'm'
                'stage 1 stator blade count', fmt(R.NbS1), '-'
                'stage 1 rotor blade count', fmt(R.NbR1), '-'
                'stage 2 stator blade count', fmt(R.NbS2), '-'
                'stage 2 rotor blade count', fmt(R.NbR2), '-'
                };
            cla(app.StatorAerofoilAxes); cla(app.RotorAerofoilAxes);
            mS = str2double(app.NacaSmEdit.Value); pS = str2double(app.NacaSpEdit.Value); tS = str2double(app.NacaStEdit.Value);
            mR = str2double(app.NacaRmEdit.Value); pR = str2double(app.NacaRpEdit.Value); tR = str2double(app.NacaRtEdit.Value);
            x = linspace(0,1,200);
            [ycS,ytS] = naca4_camber_thickness(x,mS,pS,tS); plot(app.StatorAerofoilAxes, x, ycS+ytS, x, ycS-ytS); grid(app.StatorAerofoilAxes,'on'); axis(app.StatorAerofoilAxes,'tight');
            [ycR,ytR] = naca4_camber_thickness(x,mR,pR,tR); plot(app.RotorAerofoilAxes,  x, ycR+ytR, x, ycR-ytR); grid(app.RotorAerofoilAxes,'on'); axis(app.RotorAerofoilAxes,'tight');

            plotTurbine3D(app,R);
            drawnow;
        end


    end

    methods (Access = public)
        function app = RocketTATGbyAliAerospace
            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0, clear app;
            end
        end

        function delete(app)
            if isvalid(app.UIFigure), delete(app.UIFigure);
            end
        end
    end
end

%functions extra
function ef = mkRow(gl, rowIndex, labelText, useLatex)
lab = uilabel(gl,'Text',labelText);
if useLatex, lab.Interpreter = 'latex';
end
lab.Layout.Row = rowIndex; lab.Layout.Column = 1;

ef = uieditfield(gl,'text','Value','');  
ef.Layout.Row = rowIndex; ef.Layout.Column = 2;
end

function mkLabel(gl, colIndex, txt, useLatex)
lab = uilabel(gl,'Text',txt);
if useLatex, lab.Interpreter = 'latex';
end
lab.Layout.Row = 1; lab.Layout.Column = colIndex;
end

function ef = mkEdit(gl, colIndex)
ef = uieditfield(gl,'text','Value','');  
ef.Layout.Row = 1; ef.Layout.Column = colIndex;
end

function [yc,yt] = naca4_camber_thickness(x,m,p,t)
yt = 5*t*(0.2969*sqrt(x) - 0.1260*x - 0.3516*x.^2 + 0.2843*x.^3 - 0.1015*x.^4);
yc = zeros(size(x));
for i = 1:numel(x)
    if x(i) < p
        yc(i) = m/p^2*(2*p*x(i) - x(i)^2);
    else
        yc(i) = m/(1-p)^2*((1-2*p) + 2*p*x(i) - x(i)^2);
    end
end
end

function plotTurbine3D(app,R)
%turbine plot

ax = app.VisualAxes;
cla(ax);
hold(ax,'on');
grid(ax,'on');

%this code is from my raw code before I made the UI. For insights, just
%contact me 
%grid sizing
Nr = 10;
Nx = 10;
r  = linspace(R.rhub,R.rtip,Nr);
x  = linspace(0,1,Nx);

omega = R.U/R.r_m;

cS  = R.cS;
cR  = R.cR;
gap = R.gap;

xS1 = 0.000;
xR1 = xS1 + cS + gap;
xS2 = xR1 + cR + gap;
xR2 = xS2 + cS + gap;

Ca = R.Ca;

Cw2m_1 = Ca*tan(R.alpha2_1);
Cw3m_1 = Ca*tan(R.alpha3_1);
Cw2m_2 = Ca*tan(R.alpha2_2);
Cw3m_2 = Ca*tan(R.alpha3_2);

Cw2_1 = Cw2m_1*(R.r_m./r);
Cw3_1 = Cw3m_1*(R.r_m./r);
Cw2_2 = Cw2m_2*(R.r_m./r);
Cw3_2 = Cw3m_2*(R.r_m./r);

U_r = omega*r;

a1S1 = zeros(size(r));
a2S1 = atan(Cw2_1./Ca);

b2R1 = atan((Cw2_1 - U_r)./Ca);
b3R1 = atan((Cw3_1 - U_r)./Ca);

a1S2 = atan(Cw3_1./Ca);
a2S2 = atan(Cw2_2./Ca);

b2R2 = atan((Cw2_2 - U_r)./Ca);
b3R2 = atan((Cw3_2 - U_r)./Ca);

s = 3*x.^2 - 2*x.^3;

ThS1 = build_theta(r,x,s,a1S1,a2S1,cS);
ThR1 = build_theta(r,x,s,b2R1,b3R1,cR);
ThS2 = build_theta(r,x,s,a1S2,a2S2,cS);
ThR2 = build_theta(r,x,s,b2R2,b3R2,cR);
secS.m = str2double(app.NacaSmEdit.Value);
secS.p = str2double(app.NacaSpEdit.Value);
secS.t = str2double(app.NacaStEdit.Value);
secS.N = 220;
secR.m = str2double(app.NacaRmEdit.Value);
secR.p = str2double(app.NacaRpEdit.Value);
secR.t = str2double(app.NacaRtEdit.Value);
secR.N = 240;
plot_row_airfoil(ax,r,x,ThS1,xS1,cS,R.NbS1,secS,0);
plot_row_airfoil(ax,r,x,ThR1,xR1,cR,R.NbR1,secR,0);
plot_row_airfoil(ax,r,x,ThS2,xS2,cS,R.NbS2,secS,0);
plot_row_airfoil(ax,r,x,ThR2,xR2,cR,R.NbR2,secR,0);

Nt = 160;
NxC = 30;
th = linspace(0,2*pi,Nt);
add_cyl(ax,xS1,cS,r(1),th,NxC);
add_cyl(ax,xR1,cR,r(1),th,NxC);
add_cyl(ax,xS2,cS,r(1),th,NxC);
add_cyl(ax,xR2,cR,r(1),th,NxC);

axis(ax,'equal');
xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
view(ax,45,25);
camlight(ax,'headlight');
lighting(ax,'gouraud');
hold(ax,'off');
end

function Theta = build_theta(r,x,s,angLE,angTE,c)
Nr = numel(r); Nx = numel(x);
Theta = zeros(Nr,Nx);
xx = c*x;
for i = 1:Nr
    ang = angLE(i) + (angTE(i)-angLE(i))*s;
    dth_dx = tan(ang)/r(i);
    th = cumtrapz(xx,dth_dx);
    Theta(i,:) = th - th(1);
end
end

function plot_row_airfoil(ax,r,xgrid,Theta,x0,c,Nb,sec,thetaOffset)
xsec = linspace(0,1,sec.N);
[yc,yt] = naca4_camber_thickness(xsec,sec.m,sec.p,sec.t);

Nr = numel(r);
xxg = c*xgrid;

Thsec = zeros(Nr,numel(xsec));
Chisec = zeros(Nr,numel(xsec));

for i = 1:Nr
    thx = gradient(Theta(i,:),xxg);
    chi = atan(r(i)*thx);
    Thsec(i,:) = interp1(xgrid,Theta(i,:),xsec,'pchip','extrap');
    Chisec(i,:) = interp1(xgrid,chi,xsec,'pchip','extrap');
end

ynU = c*(yc + yt);
ynL = c*(yc - yt);

XU0 = zeros(Nr,numel(xsec)); YU0 = XU0; ZU0 = XU0;
XL0 = zeros(Nr,numel(xsec)); YL0 = XL0; ZL0 = XL0;
for i = 1:Nr
    chi = Chisec(i,:);
    th0 = thetaOffset + Thsec(i,:);

    xbase = x0 + c*xsec;
    xU = xbase - ynU.*sin(chi);
    xL = xbase - ynL.*sin(chi);

    thU = th0 + (ynU.*cos(chi))/r(i);
    thL = th0 + (ynL.*cos(chi))/r(i);

    XU0(i,:) = xU;
    XL0(i,:) = xL;
    YU0(i,:) = r(i)*sin(thU);  ZU0(i,:) = r(i)*cos(thU);
    YL0(i,:) = r(i)*sin(thL);  ZL0(i,:) = r(i)*cos(thL);
end

Xle0  = [XU0(:,1)  XL0(:,1) ];  Yle0  = [YU0(:,1)  YL0(:,1) ];  Zle0  = [ZU0(:,1)  ZL0(:,1) ];
Xte0  = [XU0(:,end) XL0(:,end)]; Yte0 = [YU0(:,end) YL0(:,end)]; Zte0 = [ZU0(:,end) ZL0(:,end)];
Xhub0 = [XU0(1,:);  XL0(1,:) ];  Yhub0 = [YU0(1,:);  YL0(1,:) ];  Zhub0 = [ZU0(1,:);  ZL0(1,:) ];
Xtip0 = [XU0(end,:); XL0(end,:)]; Ytip0 = [YU0(end,:); YL0(end,:)]; Ztip0 = [ZU0(end,:); ZL0(end,:)];

for k = 0:Nb-1
    thk = 2*pi*k/Nb;
    ct = cos(thk); st = sin(thk);
    YU =  YU0*ct - ZU0*st;  ZU = YU0*st + ZU0*ct;
    YL =  YL0*ct - ZL0*st;  ZL = YL0*st + ZL0*ct;

    Yle = Yle0*ct - Zle0*st; Zle = Yle0*st + Zle0*ct;
    Yte = Yte0*ct - Zte0*st; Zte = Yte0*st + Zte0*ct;
    Yhub = Yhub0*ct - Zhub0*st; Zhub = Yhub0*st + Zhub0*ct;
    Ytip = Ytip0*ct - Ztip0*st; Ztip = Ytip0*st + Ztip0*ct;
    surf(ax,XU0,YU,ZU,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0.6 0.6 0.6]);
    surf(ax,XL0,YL,ZL,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0.6 0.6 0.6]);

    surf(ax,Xle0,Yle,Zle,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0.6 0.6 0.6]);
    surf(ax,Xte0,Yte,Zte,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0.6 0.6 0.6]);

    surf(ax,Xhub0,Yhub,Zhub,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0.6 0.6 0.6]);
    surf(ax,Xtip0,Ytip,Ztip,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0.6 0.6 0.6]);
end
end
function add_cyl(ax,x0,c,r0,th,NxC)
xv = linspace(x0,x0+c,NxC);
[TH,XX] = meshgrid(th,xv);
Y = r0*sin(TH);
Z = r0*cos(TH);
surf(ax,XX,Y,Z,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0.6 0.6 0.6]);
end
