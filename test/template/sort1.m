clc
clear
close all

% 2D points, both coordinates in the range [-1,1]
XY = rand(1000,2)*2 - 1;

% define equal-sized bins that divide the [-1,1] grid into 10x10 quadrants
mn = [-1 -1]; mx = [1 1];  % mn = min(XY); mx = max(XY);
N = 10;
edges = linspace(mn(1), mx(1), N+1);

% map points to bins
% We fix HISTC handling of last edge, so the intervals become:
% [-1, -0.8), [-0.8, -0.6), ..., [0.6, 0.8), [0.8, 1]
% (note the last interval is closed on the right side)
[~,subs] = histc(XY, edges, 1);  %#ok<HISTC>
subs(subs==N+1) = N;

% 2D histogram of bins count
H = accumarray(subs, 1, [N N]);

% plot histogram
imagesc(H.'); axis image xy
set(gca, 'TickDir','out')
colormap gray; colorbar
xlabel('X'); ylabel('Y')

% show bin intervals
ticks = (0:N)+0.5;
labels = strtrim(cellstr(num2str(edges(:),'%g')));
set(gca, 'XTick',ticks, 'XTickLabel',labels, ...
    'YTick',ticks, 'YTickLabel',labels)

% plot 2D points on top, correctly scaled from [-1,1] to [0,N]+0.5
XY2 = bsxfun(@rdivide, bsxfun(@minus, XY, mn), mx-mn) * N + 0.5;
line(XY2(:,1), XY2(:,2), 'LineStyle','none', 'Marker','.', 'Color','r')