function selector = GetSelector()

%%% selector for category measurement
%%% 1st:    feature's range
%%% 2nd:    max_n
%%% 3rd:    topm

selector{1}{1} = 1:3043;  % all measurement
selector{1}{2} = [1,5,10, 25:25:100];
selector{2}{1} = 1:13;    % packet number
selector{2}{2} = [1, 5, 10, 13];
selector{3}{1} = 14:37;   % packet time
selector{3}{2} = [1,5:5:20, 24];
selector{4}{1} = 38:161;  % ngram
selector{4}{2} = [1,5,10, 25:25:100];
selector{5}{1} = 162:765; % trans position
selector{5}{2} = [1,5,10, 25:25:100];
selector{6}{1} = 766:1365;    % knn interval
selector{6}{2} = [1,5,10, 25:25:100];
selector{7}{1} = 1366:1967;   % icics interval
selector{7}{2} = [1,5,10, 25:25:100];
selector{8}{1} = 1968:2553;   % wpes 11
selector{8}{2} = [1,5,10, 25:25:100];
selector{9}{1} = 2554:2778;   % pkt distribution
selector{9}{2} = [1,5,10, 25:25:100];
selector{10}{1} = 2779:2789;   % burst
selector{10}{2} = [1, 5, 10, 11];
selector{11}{1} = 2790:2809;   % first 20
selector{11}{2} = [1,5,10,15,20];
selector{12}{1} = 2810:2811;   % first 30, packet number
selector{12}{2} = [2];
selector{13}{1} = 2812:2813;   % last 30, packet number
selector{13}{2} = [2];
selector{14}{1} = 2814:2939;   % pkt per second
selector{14}{2} = [1,5,10,25:25:100];
selector{15}{1} = 2940:3043;   % cumul features
selector{15}{2} = [1,5,10, 25:25:100];

end
