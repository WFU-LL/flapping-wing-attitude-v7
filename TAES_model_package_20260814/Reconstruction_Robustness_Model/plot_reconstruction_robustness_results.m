function plot_reconstruction_robustness_results()
% Generate publication-ready Fig. 9 and Fig. 10 from final CSV evidence.

cfg=init_recon_robustness_config();
table_vii=readtable(fullfile(cfg.dirs.tables,'TableVII.csv'), ...
    'TextType','string');
gain=readtable(fullfile(cfg.output_dir,'gain_sweep_summary.csv'), ...
    'TextType','string');
controller_summary=readtable(fullfile(cfg.output_dir, ...
    'controller_comparison_summary.csv'),'TextType','string');
figure_dir=cfg.dirs.figures;

colors.blue=[54 103 173]/255;
colors.green=[65 133 98]/255;
colors.purple=[126 91 166]/255;
colors.orange=[198 126 73]/255;
colors.gray=[105 112 120]/255;
colors.light=[0.88 0.91 0.95];

fig9=figure('Color','w','Units','inches','Position',[0.5 0.5 7.2 5.5]);
tiledlayout(fig9,2,3,'TileSpacing','compact','Padding','compact');

ax=nexttile;part=table_vii(table_vii.stage=="stage3",:);
x=arrayfun(@(s)sscanf(char(erase(s,"bias_")),'%f'),part.scenario_id);
plot_interval(ax,x,part,colors.blue);xlabel(ax, ...
    ['Reconstruction gain bias, ' char(948)],'Interpreter','none');
ylabel(ax,'Median RMSE reduction (%)');panel(ax,'a');title(ax,'Gain bias');

ax=nexttile;part=table_vii(table_vii.stage=="stage4",:);
x=arrayfun(@(s)sscanf(char(erase(erase(s,"delay_"),"ms")),'%f'),part.scenario_id);
plot_interval(ax,x,part,colors.green);xlabel(ax,'Delay (ms)');panel(ax,'b');title(ax,'Delay');

ax=nexttile;part=table_vii(table_vii.stage=="stage5",:);
x=arrayfun(@(s)sscanf(char(erase(s,"noise_")),'%f'),part.scenario_id);
plot_interval(ax,x,part,colors.purple);xlabel(ax, ...
    ['Noise RMS fraction, ' char(947)],'Interpreter','none');
panel(ax,'c');title(ax,'Band-limited noise');

ax=nexttile;part=table_vii(table_vii.stage=="stage6",:);
x=1:height(part);hold(ax,'on');
errorbar(ax,x,part.median_rmse_reduction_pct, ...
    part.median_rmse_reduction_pct-part.bootstrap_ci_low_pct, ...
    part.bootstrap_ci_high_pct-part.median_rmse_reduction_pct, ...
    'o-','Color',colors.blue,'MarkerFaceColor','w','LineWidth',1.2, ...
    'MarkerSize',4,'CapSize',4);
set(ax,'XTick',x,'XTickLabel',replace(part.scenario_id,"_"," "));
xtickangle(ax,18);ylabel(ax,'Median RMSE reduction (%)');
panel(ax,'d');title(ax,'Combined imperfections');grid(ax,'on');

ax=nexttile;hold(ax,'on');
bar(ax,x,part.p95_energy_ratio,0.58,'FaceColor',colors.orange, ...
    'EdgeColor','none');
yline(ax,1.5,'--','Color',colors.gray,'LineWidth',1.0, ...
    'HandleVisibility','off');
text(ax,0.04,0.94,'Criterion: 1.5','Units','normalized','FontSize',6.8, ...
    'Color',colors.gray,'VerticalAlignment','top');
set(ax,'XTick',x,'XTickLabel',replace(part.scenario_id,"_"," "));
xtickangle(ax,18);ylabel(ax,'p95 control-energy ratio');ylim(ax,[0 1.6]);
panel(ax,'e');title(ax,'Energy constraint');grid(ax,'on');

ax=nexttile;part=table_vii(table_vii.stage=="stage7",:);
unfiltered=part(part.controller=="C1_selective",:);
lpf=part(part.controller=="C3_selective_LPF",:);
fc=arrayfun(@(s)sscanf(char(extractBetween(s,"lpf_","Hz")),'%f'),lpf.scenario_id);
hold(ax,'on');yyaxis(ax,'left');
h_rmse=plot(ax,fc,lpf.median_rmse_reduction_pct,'o-','Color',colors.purple, ...
    'MarkerFaceColor','w','LineWidth',1.2,'MarkerSize',4);
yline(ax,unfiltered.median_rmse_reduction_pct,':', ...
    'Color',colors.purple,'LineWidth',1.0,'HandleVisibility','off');
ylabel(ax,'Median RMSE reduction (%)');
yyaxis(ax,'right');
h_energy=plot(ax,fc,lpf.p95_energy_ratio,'s-','Color',colors.orange, ...
    'MarkerFaceColor','w','LineWidth',1.2,'MarkerSize',4);
yline(ax,1.5,'--','Color',colors.gray,'LineWidth',1.0, ...
    'HandleVisibility','off');
ylabel(ax,'p95 energy ratio');xlabel(ax,'LPF cutoff (Hz)');
panel(ax,'f');title(ax,'Causal LPF');grid(ax,'on');
legend(ax,[h_rmse,h_energy],{'RMSE reduction','Energy ratio'}, ...
    'Location','southoutside','Orientation','horizontal');

style_figure(fig9);
export_all(fig9,fullfile(figure_dir,'Fig9_reconstruction_robustness'));
close(fig9);

fig10=figure('Color','w','Units','inches','Position',[0.5 0.5 7.2 4.8]);
tiledlayout(fig10,2,2,'TileSpacing','compact','Padding','compact');
agg=groupsummary(gain,{'controller','k_roll'},'mean', ...
    {'rmse_reduction_pct','energy_ratio','pitch_energy_ratio'});
controllers=["C1_selective","C2_all_axis"];
labels=["Selective roll/yaw","All-axis"];
line_colors={colors.blue,colors.orange};
metrics={'mean_rmse_reduction_pct','mean_energy_ratio','mean_pitch_energy_ratio'};
titles={'Tracking benefit','Total control effort','Pitch-channel effort'};
ylabels={'Mean RMSE reduction (%)','Mean control-energy ratio', ...
    'Mean pitch-energy ratio'};
for mi=1:3
    ax=nexttile;hold(ax,'on');
    for ci=1:2
        part=agg(agg.controller==controllers(ci),:);
        plot(ax,part.k_roll,part.(metrics{mi}),'o-','Color',line_colors{ci}, ...
            'MarkerFaceColor','w','LineWidth',1.3,'MarkerSize',4, ...
            'DisplayName',labels(ci));
    end
    xline(ax,0.3,':','Color',colors.gray,'LineWidth',1.0, ...
        'HandleVisibility','off');
    yl=ylim(ax);text(ax,0.31,yl(2)-0.06*diff(yl),'k = 0.30', ...
        'Rotation',0,'FontSize',6.6,'Color',colors.gray, ...
        'VerticalAlignment','top','HorizontalAlignment','left');
    xlabel(ax,'Compensation gain, k');ylabel(ax,ylabels{mi});
    title(ax,titles{mi});panel(ax,char('a'+mi-1));grid(ax,'on');
    if mi==1,legend(ax,'Location','northwest');end
end
ax=nexttile;hold(ax,'on');
trade=groupsummary(controller_summary,'controller','mean', ...
    {'median_rmse_reduction_pct','p95_energy_ratio'});
for ci=1:2
    part=trade(trade.controller==controllers(ci),:);
    scatter(ax,part.mean_p95_energy_ratio, ...
        part.mean_median_rmse_reduction_pct,52,line_colors{ci},'filled', ...
        'MarkerEdgeColor','w','LineWidth',0.8);
    if ci==2
        xtext=part.mean_p95_energy_ratio-0.10;align='right';
    else
        xtext=part.mean_p95_energy_ratio-0.08;align='right';
    end
    text(ax,xtext,part.mean_median_rmse_reduction_pct,labels(ci), ...
        'FontSize',7.0,'Color',line_colors{ci},'VerticalAlignment','middle', ...
        'HorizontalAlignment',align);
end
xline(ax,1.5,'--','Energy criterion','Color',colors.gray, ...
    'LineWidth',1.0,'LabelVerticalAlignment','bottom','FontSize',6.5);
xlabel(ax,'Mean p95 control-energy ratio');
ylabel(ax,'Mean median RMSE reduction (%)');
title(ax,'N = 100 paired trade-off');panel(ax,'d');grid(ax,'on');
xlim(ax,[0.8 6.0]);
style_figure(fig10);
export_all(fig10,fullfile(figure_dir,'Fig10_controller_structure_tradeoff'));
close(fig10);
fprintf('RECON_FIGURES_COMPLETE\n');
end

function plot_interval(ax,x,part,color)
[x,order]=sort(x);part=part(order,:);hold(ax,'on');
fill(ax,[x(:);flipud(x(:))], ...
    [part.bootstrap_ci_low_pct;flipud(part.bootstrap_ci_high_pct)], ...
    0.86*[1 1 1]+0.14*color,'FaceAlpha',1,'EdgeColor','none');
plot(ax,x,part.median_rmse_reduction_pct,'o-','Color',color, ...
    'MarkerFaceColor','w','LineWidth',1.2,'MarkerSize',4);
yline(ax,0,'--','Color',[0.5 0.5 0.5],'LineWidth',0.8);
grid(ax,'on');
end

function panel(ax,label)
text(ax,-0.14,1.07,label,'Units','normalized','FontWeight','bold', ...
    'FontSize',8,'VerticalAlignment','top');
end

function style_figure(fig)
axes_list=findall(fig,'Type','axes');
for i=1:numel(axes_list)
    set(axes_list(i),'FontName','Times New Roman','FontSize',7.2, ...
        'LineWidth',0.7,'Box','off','TickDir','out','Layer','top');
end
set(findall(fig,'Type','text'),'FontName','Times New Roman');
end

function export_all(fig,base)
exportgraphics(fig,[base '.png'],'Resolution',600,'BackgroundColor','white');
exportgraphics(fig,[base '.pdf'],'ContentType','vector','BackgroundColor','white');
print(fig,[base '.svg'],'-dsvg','-vector');
end
