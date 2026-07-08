function refined_publication_framework_v7_final_source()
%REFINED_PUBLICATION_FRAMEWORK_V7_FINAL_SOURCE
% Publication-grade standalone framework figure for the tuned V7
% flapping-wing attitude model. This script only draws a visual figure; it
% does not load, modify, simulate, or tune the Simulink model.

rootDir = fileparts(mfilename('fullpath'));
pngFile = fullfile(rootDir, 'refined_publication_framework_v7_final.png');
pdfFile = fullfile(rootDir, 'refined_publication_framework_v7_final.pdf');
svgFile = fullfile(rootDir, 'refined_publication_framework_v7_final.svg');

style.font = 'Arial';
style.titleBlue = '#0B2E83';
style.subtitleGray = '#4B5563';
style.control = '#1E56B3';
style.controlFill = '#F2F7FF';
style.feedback = '#2F7A4E';
style.feedbackFill = '#F2FBF5';
style.flex = '#7A56C1';
style.flexFill = '#F7F2FF';
style.analysis = '#7C7C7C';
style.analysisFill = '#F7F7F7';
style.plantEdge = '#24456E';
style.plantFill = '#F4F8FB';
style.formulaFill = '#EAF2FF';
style.text = '#111827';
style.lightText = '#374151';

fig = figure('Color', 'w', 'Units', 'inches', ...
    'Position', [0.5 0.5 18.2 10.2], 'Renderer', 'painters');
ax = axes('Parent', fig, 'Position', [0 0 1 1]);
axis(ax, [0 100 0 58]);
axis(ax, 'off');
hold(ax, 'on');

drawTitleBand(ax, [21.5 51.0 57.0 4.6], style);

% Main modules
drawBox(ax, [2.2 39.0 15.4 9.0], 'Reference Attitude Commands', ...
    {'r = [\phi_r, \theta_r, \psi_r]^T', '', ...
     'roll reference    \phi_r', ...
     'pitch reference   \theta_r', ...
     'yaw reference     \psi_r'}, ...
    style.control, style.controlFill, style.titleBlue, 10.5, 8.2, 1.35, style.font);

drawBox(ax, [2.2 20.5 15.4 9.5], 'Measured States / Feedback States', ...
    {'x = [\phi, \theta, \psi, p, q, r]^T', '', ...
     '\phi, \theta, \psi: Euler angles', ...
     'p, q, r: body rates'}, ...
    style.feedback, style.feedbackFill, '#166534', 10.2, 8.1, 1.35, style.font);

drawBox(ax, [21.4 30.0 13.5 12.6], 'Attitude Controller', ...
    {'Simplified attitude controller', ...
     'for mechanism-oriented simulation', '', ...
     'Input: r, x', ...
     'Output: M_c', '', ...
     'Controller unchanged'}, ...
    style.control, style.controlFill, style.titleBlue, 10.5, 8.0, 1.35, style.font);

drawPlant(ax, [38.0 22.2 25.8 11.8], style);

drawBox(ax, [70.8 25.2 14.3 9.2], 'Attitude Responses', ...
    {'roll trajectory     \phi(t)', ...
     'pitch trajectory    \theta(t)', ...
     'yaw trajectory      \psi(t)', ...
     'state output for logging'}, ...
    style.control, style.controlFill, style.titleBlue, 10.5, 8.0, 1.35, style.font);
drawResponseIcon(ax, [80.9 31.6 2.5 1.35], '#7EA6E6');

drawBox(ax, [88.4 19.2 10.3 12.5], 'Dynamic Response Analysis', ...
    {'Post-processing only', '', ...
     'attitude response', ...
     'disturbance recovery', ...
     'frequency characteristics', ...
     'uncertainty envelope'}, ...
    style.analysis, style.analysisFill, '#4B5563', 9.0, 7.2, 1.20, style.font);

drawFlexibleModule(ax, [35.5 36.0 41.8 14.1], style);

% Main signal arrows
drawArrow(ax, [17.6 43.5; 19.0 43.5; 19.0 37.0; 21.4 37.0], style.control, 1.7, '-');
edgeLabel(ax, 20.3, 43.1, 'r = [\phi_r, \theta_r, \psi_r]^T', style.control, style.font);

drawArrow(ax, [17.6 25.4; 18.8 25.4; 18.8 32.8; 21.4 32.8], style.feedback, 1.7, '-');
edgeLabel(ax, 19.7, 25.0, 'x = [\phi, \theta, \psi, p, q, r]^T', style.feedback, style.font);

drawArrow(ax, [34.9 35.2; 36.4 35.2; 36.4 28.2; 38.0 28.2], style.control, 1.7, '-');
edgeLabel(ax, 37.6, 34.2, 'M_c = [M_x^c, M_y^c, M_z^c]^T', style.control, style.font);

drawArrow(ax, [63.8 28.4; 70.8 28.4], style.control, 1.7, '-');
edgeLabel(ax, 67.2, 29.35, 'attitude trajectories / state output', style.control, style.font);

% Feedback lower loop
drawArrow(ax, [77.9 25.2; 77.9 18.0; 9.9 18.0; 9.9 20.5], style.feedback, 1.7, '-');
edgeLabel(ax, 44.0, 17.25, '\phi, \theta, \psi, p, q, r', style.feedback, style.font);

% Flexible correction injection
drawArrow(ax, [67.0 36.0; 67.0 35.1; 51.1 35.1; 51.1 34.0], style.flex, 1.8, '-');
edgeLabel(ax, 60.0, 35.85, '\Delta M_{flex} = [\Delta M_x, \Delta M_y, \Delta M_z]^T', style.flex, style.font);

% Offline analysis
drawArrow(ax, [85.1 28.4; 88.3 28.4], style.analysis, 1.2, '--');
edgeLabel(ax, 86.75, 29.35, 'analysis outputs', style.analysis, style.font);

% Innovation blocks and lower information panels
drawInnovation(ax, [14.0 9.2 22.5 4.0], '1', 'Innovation 1:', ...
    'Flapping-wing inertial effect', '(\Delta F_{inertia} \rightarrow \Delta M_{flex})', ...
    style.control, style.controlFill, style.titleBlue, style.font);
drawInnovation(ax, [39.0 9.2 24.0 4.0], '2', 'Innovation 2:', ...
    'Flexible aerodynamic correction', ...
    '(\Delta F_{lift}, \Delta F_{thrust}, \Delta F_{drag} \rightarrow \Delta M_{flex})', ...
    style.feedback, style.feedbackFill, '#166534', style.font);
drawInnovation(ax, [66.0 9.2 24.0 4.0], '3', 'Innovation 3:', ...
    'Wake / unsteady compensation', '(\Delta F_{wake} \rightarrow \Delta M_{flex})', ...
    style.flex, style.flexFill, '#5B21B6', style.font);

drawInfoBox(ax, [2.0 1.3 24.0 5.6], 'Notes:', ...
    {'Mechanism-oriented framework.', ...
     'Tuned V7 dynamics, controller, flexible-force functions,', ...
     'and parameters are unchanged.', ...
     'Flexible correction enters the plant as additive moment \Delta M_{flex}.'}, ...
    '#9CA3AF', '#FFFFFF', style.text, style.font);

drawInfoBox(ax, [29.0 1.3 40.0 5.6], 'Symbols:', ...
    {'\eta = [\phi, \theta, \psi]^T, Euler angle vector', ...
     '\omega = [p, q, r]^T, body-rate vector', ...
     'M_c, control moment      \Delta M_{flex}, flexible-wing correction moment', ...
     'J, inertia matrix        D, damping matrix'}, ...
    '#9CA3AF', '#FFFFFF', style.text, style.font);

drawLegend(ax, [73.0 1.3 25.0 5.6], style);

drawnow;
set(fig, 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
print(fig, pngFile, '-dpng', '-r600');
print(fig, pdfFile, '-dpdf', '-painters', '-bestfit');
print(fig, svgFile, '-dsvg', '-painters');
close(fig);

fprintf('Wrote %s\n', pngFile);
fprintf('Wrote %s\n', pdfFile);
fprintf('Wrote %s\n', svgFile);
end

function drawTitleBand(ax, pos, style)
rectangle(ax, 'Position', pos, 'Curvature', [0.025 0.10], ...
    'EdgeColor', 'white', 'FaceColor', 'white', 'LineWidth', 0.1);
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
text(ax, x+w/2, y+h-1.35, 'Mechanism-Oriented Framework of the Flexible Flapping-Wing Attitude Model', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontName', style.font, 'FontWeight', 'bold', 'FontSize', 20, ...
    'Color', style.titleBlue, 'Interpreter', 'none');
text(ax, x+w/2, y+h-2.75, 'Top-level restructuring only: tuned V7 dynamics, controller, flexible-force functions, and parameters are unchanged.', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontName', style.font, 'FontAngle', 'italic', 'FontSize', 12, ...
    'Color', style.subtitleGray, 'Interpreter', 'none');
end

function drawFlexibleModule(ax, pos, style)
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
drawRoundedRect(ax, pos, style.flex, style.flexFill, 1.2, '--');
text(ax, x + w/2, y + h - 1.0, 'Proposed Flexible-Wing Correction Module', ...
    'HorizontalAlignment', 'center', 'FontName', style.font, 'FontWeight', 'bold', ...
    'FontSize', 10.5, 'Color', style.flex, 'Interpreter', 'none');
text(ax, x + w/2, y + h - 2.15, 'Innovation core', ...
    'HorizontalAlignment', 'center', 'FontName', style.font, 'FontAngle', 'italic', ...
    'FontSize', 8.3, 'Color', style.flex, 'Interpreter', 'none');

A = [x + 1.1 y + 7.1 7.8 4.5];
C = [x + 9.9 y + 7.1 9.2 4.5];
D = [x + 20.3 y + 7.1 9.3 4.5];
E = [x + 31.2 y + 7.1 8.5 4.5];
B = [x + 1.1 y + 1.7 16.7 3.7];
F = [x + 19.8 y + 1.7 17.9 3.7];

drawSubBox(ax, A, '4A Flapping Kinematics', ...
    {'\phi_w(t)', 'd\phi_w/dt', 'd^2\phi_w/dt^2', 'A_0, f_{flap}'}, style.flex, style.font);
drawFlapIcon(ax, [A(1)+0.55 A(2)+0.55 1.55 0.75], '#BFA8E8');
drawSubBox(ax, C, '4C FSI-Referenced Information', ...
    {'flexible deformation', 'aerodynamic trend extraction', 'force correction identification'}, style.flex, style.font);
drawSubBox(ax, D, '4D Correction Term Generation', ...
    {'\Delta F_{inertia}', '\Delta F_{lift}', '\Delta F_{thrust}', '\Delta F_{drag}', '\Delta F_{wake}'}, style.flex, style.font);
drawSubBox(ax, E, '4E Force-to-Moment Mapping', ...
    {'\Delta M_x', '\Delta M_y', '\Delta M_z'}, style.flex, style.font);
drawSubBox(ax, B, '4B Flapping-Wing Characteristics', ...
    {'b, c, S, AR, wing mass/inertia, k, Re'}, style.flex, style.font);
drawWingIcon(ax, [B(1)+0.75 B(2)+0.60 2.45 0.95], '#BFA8E8');
drawSubBox(ax, F, '4F Scalable Correction Gains', ...
    {'s_{inertia}, s_{flex}, s_{wake}'}, style.flex, style.font);

drawArrow(ax, [A(1)+A(3) A(2)+2.5; C(1) C(2)+2.5], style.flex, 1.45, '-');
drawArrow(ax, [C(1)+C(3) C(2)+2.5; D(1) D(2)+2.5], style.flex, 1.45, '-');
drawArrow(ax, [D(1)+D(3) D(2)+2.5; E(1) E(2)+2.5], style.flex, 1.45, '-');
drawArrow(ax, [B(1)+B(3) B(2)+2.2; D(1) D(2)+1.4], style.flex, 1.15, '-');
drawArrow(ax, [F(1)+F(3)/2 F(2)+F(4); D(1)+D(3)/2 D(2)], style.flex, 1.15, '-');
drawArrow(ax, [F(1)+F(3) F(2)+2.4; E(1)+E(3)/2 E(2)], style.flex, 1.15, '-');
text(ax, x + 18.8, y + 5.55, 'supports / informs', ...
    'FontName', style.font, 'FontSize', 7.2, 'Color', style.flex, 'Interpreter', 'none');
text(ax, x + 25.4, y + 5.55, 'modulates correction paths', ...
    'FontName', style.font, 'FontSize', 7.2, 'Color', style.flex, 'Interpreter', 'none');
end

function drawPlant(ax, pos, style)
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
drawRoundedRect(ax, pos, style.plantEdge, style.plantFill, 1.6, '-');
text(ax, x+w/2, y+h-1.0, 'Baseline Six-State Rigid-Body Attitude Plant', ...
    'HorizontalAlignment', 'center', 'FontName', style.font, 'FontWeight', 'bold', ...
    'FontSize', 10.8, 'Color', style.titleBlue, 'Interpreter', 'none');
text(ax, x+1.2, y+h-2.7, 'States:', 'FontName', style.font, ...
    'FontWeight', 'bold', 'FontSize', 8.3, 'Color', style.text, 'Interpreter', 'none');
text(ax, x+5.0, y+h-2.7, 'x = [\phi, \theta, \psi, p, q, r]^T', ...
    'FontName', style.font, 'FontSize', 8.3, 'Color', style.text, 'Interpreter', 'tex');
drawRoundedRect(ax, [x+2.0 y+3.2 w-4.0 3.2], style.formulaFill, style.formulaFill, 1.0, '-');
text(ax, x+w/2, y+5.55, 'Dynamics:', 'HorizontalAlignment', 'center', ...
    'FontName', style.font, 'FontWeight', 'bold', 'FontSize', 8.3, ...
    'Color', style.text, 'Interpreter', 'none');
text(ax, x+w/2, y+4.55, 'J\omega_dot = M_c + \Delta M_{flex} - D\omega', ...
    'HorizontalAlignment', 'center', 'FontName', style.font, 'FontSize', 8.6, ...
    'Color', style.text, 'Interpreter', 'tex');
text(ax, x+w/2, y+3.72, '\eta_dot = T(\eta)\omega', ...
    'HorizontalAlignment', 'center', 'FontName', style.font, 'FontSize', 8.6, ...
    'Color', style.text, 'Interpreter', 'tex');
text(ax, x+w/2, y+1.45, 'Core dynamics unchanged from the tuned V7 model.', ...
    'HorizontalAlignment', 'center', 'FontName', style.font, 'FontSize', 8.0, ...
    'Color', style.lightText, 'Interpreter', 'none');
drawAxesIcon(ax, [x+w-3.8 y+0.9 1.55 1.55], '#8AA0B8');
end

function drawBox(ax, pos, titleText, bodyLines, edgeColor, fillColor, titleColor, titleSize, bodySize, lw, fontName)
drawRoundedRect(ax, pos, edgeColor, fillColor, lw, '-');
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
text(ax, x+w/2, y+h-1.15, titleText, 'HorizontalAlignment', 'center', ...
    'FontName', fontName, 'FontWeight', 'bold', 'FontSize', titleSize, ...
    'Color', titleColor, 'Interpreter', 'none');
text(ax, x+w/2, y+h-3.0, strjoin(bodyLines, newline), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
    'FontName', fontName, 'FontSize', bodySize, 'Color', '#111827', ...
    'Interpreter', 'tex');
end

function drawSubBox(ax, pos, titleText, bodyLines, color, fontName)
drawRoundedRect(ax, pos, color, 'white', 1.05, '-');
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
text(ax, x+w/2, y+h-0.75, titleText, 'HorizontalAlignment', 'center', ...
    'FontName', fontName, 'FontWeight', 'bold', 'FontSize', 8.7, ...
    'Color', color, 'Interpreter', 'none');
text(ax, x+w/2, y+h-2.05, strjoin(bodyLines, newline), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
    'FontName', fontName, 'FontSize', 7.4, 'Color', '#111827', ...
    'Interpreter', 'tex');
end

function drawRoundedRect(ax, pos, edgeColor, fillColor, lw, lineStyle)
rectangle(ax, 'Position', pos, 'Curvature', [0.035 0.08], ...
    'EdgeColor', edgeColor, 'FaceColor', fillColor, ...
    'LineWidth', lw, 'LineStyle', lineStyle);
end

function drawArrow(ax, pts, color, lw, lineStyle)
plot(ax, pts(:,1), pts(:,2), 'Color', color, 'LineWidth', lw, 'LineStyle', lineStyle);
p1 = pts(end-1,:); p2 = pts(end,:);
v = p2 - p1;
if norm(v) < eps
    return;
end
u = v / norm(v);
n = [-u(2) u(1)];
headLen = 0.55;
headWid = 0.32;
tip = p2;
base = tip - headLen*u;
patch(ax, [tip(1) base(1)+headWid*n(1) base(1)-headWid*n(1)], ...
    [tip(2) base(2)+headWid*n(2) base(2)-headWid*n(2)], ...
    [0 0 0], 'FaceColor', color, 'EdgeColor', color);
end

function edgeLabel(ax, x, y, txt, color, fontName)
text(ax, x, y, txt, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'FontName', fontName, 'FontAngle', 'italic', 'FontSize', 8.2, ...
    'Color', color, 'Interpreter', 'tex', 'BackgroundColor', 'white', 'Margin', 1.0);
end

function drawInnovation(ax, pos, num, header, body, detail, edgeColor, fillColor, textColor, fontName)
drawRoundedRect(ax, pos, edgeColor, fillColor, 1.25, '--');
x = pos(1); y = pos(2); h = pos(4);
rectangle(ax, 'Position', [x+1.3 y+h/2-0.95 1.9 1.9], ...
    'Curvature', [1 1], 'EdgeColor', edgeColor, 'FaceColor', edgeColor, 'LineWidth', 1.0);
text(ax, x+2.25, y+h/2, num, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', 'FontName', fontName, 'FontWeight', 'bold', ...
    'FontSize', 10, 'Color', 'white');
text(ax, x+4.4, y+h-1.0, header, 'FontName', fontName, ...
    'FontWeight', 'bold', 'FontSize', 8.0, 'Color', textColor, 'Interpreter', 'none');
text(ax, x+4.4, y+h-2.0, body, 'FontName', fontName, ...
    'FontSize', 7.7, 'Color', '#111827', 'Interpreter', 'none');
text(ax, x+4.4, y+0.45, detail, 'FontName', fontName, ...
    'FontSize', 7.2, 'Color', '#111827', 'Interpreter', 'tex');
end

function drawInfoBox(ax, pos, titleText, lines, edgeColor, fillColor, textColor, fontName)
drawRoundedRect(ax, pos, edgeColor, fillColor, 0.9, '--');
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
text(ax, x+0.6, y+h-0.75, titleText, 'FontName', fontName, 'FontWeight', 'bold', ...
    'FontSize', 7.4, 'Color', textColor, 'Interpreter', 'none');
text(ax, x+0.6, y+h-1.65, strjoin(lines, newline), 'FontName', fontName, ...
    'FontSize', 6.8, 'Color', textColor, 'VerticalAlignment', 'top', ...
    'Interpreter', 'tex');
end

function drawLegend(ax, pos, style)
drawRoundedRect(ax, pos, '#9CA3AF', '#FFFFFF', 0.9, '-');
x = pos(1); y = pos(2); h = pos(4);
text(ax, x+1.0, y+h-0.75, 'Legend', 'FontName', style.font, ...
    'FontWeight', 'bold', 'FontSize', 7.4, 'Color', style.text);
legendLine(ax, x+1.0, y+h-1.6, style.control, '-', 'blue solid line = Control / Command Signal', style.font);
legendLine(ax, x+1.0, y+h-2.55, style.feedback, '-', 'green solid line = Feedback Signal', style.font);
legendLine(ax, x+1.0, y+h-3.50, style.flex, '-', 'purple solid line = Flexible Correction Signal', style.font);
legendLine(ax, x+1.0, y+h-4.45, style.analysis, '--', 'gray dashed line = Analysis Signal', style.font);
end

function legendLine(ax, x, y, color, lineStyle, labelText, fontName)
plot(ax, [x x+3.4], [y y], 'Color', color, 'LineWidth', 1.7, 'LineStyle', lineStyle);
text(ax, x+4.0, y, labelText, 'VerticalAlignment', 'middle', ...
    'FontName', fontName, 'FontSize', 6.9, 'Color', '#111827', 'Interpreter', 'none');
end

function drawFlapIcon(ax, pos, color)
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
t = linspace(0, 1, 40);
plot(ax, x + w*t, y + h*(0.5 + 0.35*sin(2*pi*t)), ...
    'Color', color, 'LineWidth', 0.8);
end

function drawWingIcon(ax, pos, color)
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
patch(ax, [x x+w x+w*0.85 x+w*0.15], [y+h*0.3 y+h*0.05 y+h*0.85 y+h*0.65], ...
    [0 0 0], 'FaceColor', color, 'FaceAlpha', 0.10, 'EdgeColor', color, 'LineWidth', 0.8);
plot(ax, [x x+w], [y+h*0.3 y+h*0.05], 'Color', color, 'LineWidth', 0.7);
plot(ax, [x x+w*0.15], [y+h*0.3 y+h*0.65], 'Color', color, 'LineWidth', 0.7);
end

function drawAxesIcon(ax, pos, color)
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
drawArrow(ax, [x+0.4 y+0.4; x+w-0.2 y+0.4], color, 0.8, '-');
drawArrow(ax, [x+0.4 y+0.4; x+0.4 y+h-0.1], color, 0.8, '-');
drawArrow(ax, [x+0.4 y+0.4; x+w*0.8 y+h*0.75], color, 0.8, '-');
end

function drawResponseIcon(ax, pos, color)
x = pos(1); y = pos(2); w = pos(3); h = pos(4);
t = linspace(0, 1, 30);
plot(ax, x+w*t, y+h*(0.75-0.45*t+0.08*sin(10*t)), 'Color', color, 'LineWidth', 0.8);
plot(ax, x+w*t, y+h*(0.55-0.25*t+0.06*sin(8*t+1)), 'Color', color, 'LineWidth', 0.8);
plot(ax, x+w*t, y+h*(0.35-0.15*t+0.04*sin(7*t+2)), 'Color', color, 'LineWidth', 0.8);
end
