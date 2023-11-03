%% Opetogenetics function for App
function Optogenetics_func_for_App(app)
    %% Input parameters
    pre_period = app.pre_period; % unit:s
    cycle_number = app.cycle_number;
    post_period = app.post_period; % unit:s
    
    stage1_switch = app.Stage1Switch.Value; % "On" or "Off"
    stage1_duration = app.stage1_duration; % unit: s
    stage1_red_freq = app.stage1_red_freq; % unit:Hz
    stage1_red_duty_ratio = app.stage1_red_duty_ratio; % unit:%
    stage1_blue_freq = app.stage1_blue_freq;
    stage1_blue_duty_ratio = app.stage1_blue_duty_ratio;
    
    stage2_switch = app.Stage2Switch.Value;
    stage2_duration = app.stage2_duration;
    stage2_red_freq = app.stage2_red_freq;
    stage2_red_duty_ratio = app.stage2_red_duty_ratio;
    stage2_blue_freq = app.stage2_blue_freq;
    stage2_blue_duty_ratio = app.stage2_blue_duty_ratio;
    
    stage3_switch = app.Stage3Switch.Value;
    stage3_duration = app.stage3_duration;
    stage3_red_freq = app.stage3_red_freq;
    stage3_red_duty_ratio = app.stage3_red_duty_ratio;
    stage3_blue_freq = app.stage3_blue_freq;
    stage3_blue_duty_ratio = app.stage3_blue_duty_ratio;
    
    stage4_switch = app.Stage4Switch.Value;
    stage4_duration = app.stage4_duration;
    stage4_red_freq = app.stage4_red_freq;
    stage4_red_duty_ratio = app.stage4_red_duty_ratio;
    stage4_blue_freq = app.stage4_blue_freq;
    stage4_blue_duty_ratio = app.stage4_blue_duty_ratio;

    stage_number = 4;
    switch_list = [
        string(stage1_switch); 
        string(stage2_switch); 
        string(stage3_switch); 
        string(stage4_switch)
        ];
    % change char to string so that it is string array, otherwise 
    % dimensions of arrays (char) being concatenated are not consistent.
    duration_list = [
        stage1_duration;
        stage2_duration;
        stage3_duration;
        stage4_duration
        ];
    red_freq_list = [
        stage1_red_freq;
        stage2_red_freq;
        stage3_red_freq;
        stage4_red_freq
        ];
    red_duty_ratio_list = [
        stage1_red_duty_ratio;
        stage2_red_duty_ratio;
        stage3_red_duty_ratio;
        stage4_red_duty_ratio
        ];
    blue_freq_list = [
        stage1_blue_freq;
        stage2_blue_freq;
        stage3_blue_freq;
        stage4_blue_freq
        ];
    blue_duty_ratio_list = [
        stage1_blue_duty_ratio;
        stage2_blue_duty_ratio;
        stage3_blue_duty_ratio;
        stage4_blue_duty_ratio
        ];

    %% get vendor and daq
    % vendor_list = daqvendorlist;
    % daq_list = daqlist;
    % disp(daq_list{1, "DeviceInfo"}); 
    % % the printed info includes channel names (channelID), which are the 
    % % input for functions addinput and addoutput.
    d = daq("ni");
    
    %% add output channels
    addoutput(d, "Dev3", 0:1, "Voltage");
    % disp(d.Channels);

    % rate settings
    multiplier = 1; % for rate Hz, 1 means 1000 Hz
    d.Rate = 1000 * multiplier;
    
    %% signal settings
    % note: red uses the Analog Output 0; blue uses the Analog Output 1.

    % signalData for pre-period
    pre_signalData = [3 * ones(1, 500); 3 * ones(1, 500)]; % at least 500 scans required by NiDAQ

    % signalData for post-period
    post_signalData = [zeros(1, 500); zeros(1, 500)]; 
    
    sti_signalData_cell = {};
    new_duration_list = [];
    for j = 1:stage_number 
        if switch_list(j) == "On"
            % parameters for red
            t_pulse_red = (d.Rate / red_freq_list(j)) * red_duty_ratio_list(j) / 100; % how many scans
            t_zero_red = (d.Rate / red_freq_list(j)) - t_pulse_red; % how many scans
            % parameters for blue
            t_pulse_blue = (d.Rate / blue_freq_list(j)) * blue_duty_ratio_list(j) / 100; % how many scans
            t_zero_blue = (d.Rate / blue_freq_list(j)) - t_pulse_blue; % how many scans

            sti_signalData_red = [3 * ones(1, t_pulse_red), zeros(1, t_zero_red)];
            sti_signalData_blue = [3 * ones(1, t_pulse_blue), zeros(1, t_zero_blue)];

            scan_number  = max(duration_list(j) * d.Rate, 500); % at least 500 scans required by NiDAQ
            sti_signalData_red = repmat(sti_signalData_red, 1, ceil(scan_number / (t_pulse_red + t_zero_red)));
            sti_signalData_blue = repmat(sti_signalData_blue, 1, ceil(scan_number / (t_pulse_blue + t_zero_blue)));
            sti_signalData_red = sti_signalData_red(1:scan_number);
            sti_signalData_blue = sti_signalData_blue(1:scan_number);

            sti_signalData_ = [sti_signalData_red; sti_signalData_blue];
            sti_signalData_cell{end+1} = sti_signalData_;
            new_duration_list(end+1) = duration_list(j);
        end    
    end
    
    %% start output
    % note: red uses the Analog Output 0; blue uses the Analog Output 1.
    
    disp_info = "Now is pre-period.";
    disp(disp_info);
    app.OutputTextArea.Value = [app.OutputTextArea.Value; disp_info];
    app.OutputTextArea.scroll('bottom');

    start(d,"RepeatOutput");
    write(d, pre_signalData');
    pause(pre_period);
    stop(d);

    for i = 1:cycle_number
        disp_info = "Current cycle is " + num2str(i);
        disp(disp_info);
        app.OutputTextArea.Value = [app.OutputTextArea.Value; disp_info];
        app.OutputTextArea.scroll('bottom');

        for j = 1:length(sti_signalData_cell)
            sti_signalData = sti_signalData_cell{j};

            disp_info = "Stage " + num2str(j);
            disp(disp_info);
            app.OutputTextArea.Value = [app.OutputTextArea.Value; disp_info];
            app.OutputTextArea.scroll('bottom');

            start(d,"RepeatOutput");
            write(d, sti_signalData');
            pause(new_duration_list(j));
            stop(d);
        end
    end
    
    disp_info = "Now is post-period.";
    disp(disp_info);
    app.OutputTextArea.Value = [app.OutputTextArea.Value; disp_info];
    app.OutputTextArea.scroll('bottom');

    start(d,"RepeatOutput");
    write(d, post_signalData');
    pause(post_period);
    stop(d);
end