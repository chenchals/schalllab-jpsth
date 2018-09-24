
% http://www.translationalneuromodeling.org/tags/eeg/

x = 0:0.1:100;

y1 = cos(x'*pi/2);
y2 = cos(x'*pi/5+0.7);
y3 = cos(x'*pi/7+0.4);

y = y1+y2+y3;

% Hilbert Transform
h = hilbert(y);
h1 = hilbert(y1);
h2 = hilbert(y2);
h3 = hilbert(y3);
