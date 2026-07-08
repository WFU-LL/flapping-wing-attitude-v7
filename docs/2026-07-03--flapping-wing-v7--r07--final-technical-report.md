---
type: final-technical-report
date: 2026-07-03
experiment_line: flapping-wing-attitude-simulation
round: 7
purpose: final-technical-report
status: completed
source_artifacts:
  - simulation_results_v4/v4_results_for_gpt_review.md
  - simulation_results_v5/v5_results_for_gpt_review.md
  - simulation_results_v6/v6_results_for_gpt_review.md
  - simulation_results_v7/v6_v7_equivalence_report.txt
  - simulation_results_v7/flapping_wing_v7_report.txt
  - simulation_results_v7/sensitivity_report_v7.txt
linked_results:
  - flapping_wing_attitude_plant_v7.slx
---

# V1-V7 扑翼姿态动力学仿真最终技术报告

## 1. 报告定位与核心结论

本报告基于 V7 最终结果整理，不再继续修改模型。当前结论应表述为：基于文献近似参数与等效柔性翼修正项，建立并验证了一个简化六状态扑翼姿态动力学 Simulink Plant，用于比较刚性基线、惯性修正、柔性气动力修正和尾流修正对姿态响应的机制性影响。

V7 不是 CFD/FSI 高保真复现，也不是实机飞行复现。它的合理定位是“简化机理仿真”和“控制/动力学接口验证”：柔性翼效应不再作为 NAVION 固定翼模型中的等效扰动强行注入，而是直接作为力矩项进入扑翼姿态转动动力学。

V7 的关键验证结果为：

- V7 已建立真实可运行的 Simulink 动态模型 `flapping_wing_attitude_plant_v7.slx`；
- 四组最终结果由 `sim('flapping_wing_attitude_plant_v7')` 生成；
- V7 Simulink 与 V6 ode45 结果最大姿态差为 `6.19443716062783e-05 deg`，小于任务要求的 `0.05 deg`；
- 四组工况均保持有界响应，最大姿态角均为 `8 deg`；
- 柔性修正项可形成可观测、可区分的姿态响应差异，但该差异仅支持简化机理分析，不能直接推断真实飞行性能提升。

## 2. V1-V7 模型迭代过程总结

### V1：原始 L1/NAVION 固定翼模型运行与基线梳理

V1 以论文配套仓库中的 L1 自适应控制固定翼 NAVION 模型为基础，目标是让原始 Simulink 仿真在当前 MATLAB R2025b 环境中可运行，并识别主动力学通道。该阶段的重点不是加入柔性翼项，而是确认原始模型结构、初始化文件、状态变量和仿真输出方式。

在梳理中确认，原始 Plant 是固定翼 NAVION 模型，其状态向量来自 `f_NAVION.m`，并非扑翼飞行器状态：

```text
x = [u, v, w, p, q, r, phi, theta, psi, xg, yg, h]
dx = [u_dot, v_dot, w_dot, p_dot, q_dot, r_dot, phi_dot, theta_dot, psi_dot, xg_dot, yg_dot, h_dot]
```

这意味着该模型天然缺少扑翼角、扑翼角速度、扑翼柔性变形、气动-结构耦合等状态。后续柔性翼项如果继续接入 NAVION，只能解释为等效扰动注入，而不是严格的扑翼动力学建模。

### V2：柔性翼修正项接入 NAVION 主导数通道

V2 的目标是确认柔性翼修正项是否真正进入主动力学，而不是仅连接到 Scope 或 To Workspace。`signal_connection_report.txt` 显示，柔性翼模块的输出连接路径为：

```text
FlexibleWingForceComposer -> Add2 -> Integrator1
```

其中 `Add2` 的输入包括：

```text
Disturbances
f_NAVION_AC
FlexibleWingForceComposer
```

`Integrator1` 接收 `Add2` 输出，因此 V2 的柔性翼修正项确实进入了 NAVION 状态导数路径。强制放大测试也验证了接线有效性：在 `force_injection_scale = 10` 时，强注入模型相对基线产生明显差异：

```text
Max attitude difference = 61.4645853 deg
RMSE attitude difference = 19.8301024 deg
Max control input difference = 0.607680663
```

V2 的意义是证明接线不是空接；问题是该接入仍发生在固定翼 NAVION 状态导数中，柔性扑翼力项的物理对应关系不清晰，正常尺度响应也难以作为最终结论。

### V3：小增益映射、渐入函数与状态导数识别

V3 尝试将柔性翼修正项改为小增益等效扰动，并在接入前识别 NAVION 状态导数顺序。`state_mapping_report.txt` 确认了关键导数索引：

```text
idx_forward_velocity_dot_v3 = 1
idx_vertical_velocity_dot_v3 = 3
idx_roll_rate_dot_v3 = 4
idx_pitch_rate_dot_v3 = 5
idx_yaw_rate_dot_v3 = 6
```

这一步避免了盲目接线。然而 V3 没有通过最关键的零尺度等价性诊断：当 `global_correction_scale = 0` 时，V3 inertia-only 仍然与 baseline 有约 `194.674012 deg` 的最大姿态差异。这说明模型存在残余扰动、旧接线、函数缓存或模型结构不等价。V3 的非零增益结果不能解释为柔性翼效应。

### V4：从原始 baseline 重建并修复零尺度等价性

V4 不再从 V2/V3 继续复制，而是从原始 baseline 模型重新复制，并使用独立的 V4 修正函数。V4 的关键目标是保证：

```text
global_correction_scale = 0 时，柔性翼修正输出严格为 0，
且 V4 响应与 baseline 完全等价。
```

V4 结果显示：

```text
max attitude difference = 0 deg
max control input difference = 0
control energy difference = 0
PASS: V4 zero-scale model is equivalent to baseline.
```

这说明 V4 修复了 V3 的结构性问题。但 V4 的非零增益扫描仍未找到合适尺度。最大 RMSE 相对变化仅约 `4.25173875595223e-08`，远低于可观测阈值 `0.001`。因此 V4 的结论是：零尺度等价性被修复，但 NAVION 固定翼 Plant 在该小增益映射下无法提供稳定、可观测且可区分的柔性扑翼验证结果。

### V5：NAVION 通道敏感性标定

V5 保留 V4 的零尺度等价性，新增通道敏感性扫描。测试的注入通道包括：

```text
1: forward velocity derivative
2: vertical velocity derivative
3: pitch-rate derivative
4: combined forward + vertical + pitch-rate
```

V5 找到一个满足稳定性、可观测性和工况可区分性的组合：

```text
best_channel_mode = 4
best_dx_gain_multiplier = 10000
best_RMSE_change = 0.001431895315442836
best_case_separation = 0.0005617065962771977
max_angle = 20.74324834770864 deg
energy_ratio = 1.002014076563517
```

V5 的科学意义是完成 NAVION 固定翼 Plant 中的等效扰动通道敏感性标定。但它仍不能被表述为严格的柔性扑翼动力学仿真，因为柔性翼项并没有进入一个含扑翼运动状态和扑翼力矩结构的专用 Plant。

### V6：转向专用简化扑翼姿态动力学 Plant

V6 放弃继续在 NAVION 固定翼模型内调参，新增独立的六状态扑翼姿态动力学 Plant：

```text
x = [roll, pitch, yaw, p, q, r]
```

柔性翼项不再映射为 NAVION 状态导数扰动，而是直接作为转动力矩进入姿态动力学：

```text
M_total = M_control + M_flexible - D_rate * omega
```

V6 使用 ode45 脚本完成四组工况比较，结果稳定且可区分。由于 V6 主结果来自 ode45，虽然有 Simulink shell，但尚不能证明最终图和指标来自真正的 Simulink 动态模型。

### V7：固化为真正可运行的 Simulink 动态 Plant

V7 的目标是将 V6 的六状态模型固化为真实 Simulink 动态模型，并验证 Simulink 与 V6 ode45 的一致性。V7 新增 `flapping_wing_attitude_plant_v7.slx`，内部采用连续状态 Level-2 MATLAB S-function：

```text
flapping_wing_attitude_sfun_v7
NumContStates = 6
Output dimension = 18
```

输出向量包括：

```text
[x(1:6); flexible force/moment terms(1:9); controller moment(1:3)]
```

V7 验证通过后才生成最终图和指标。V6/V7 最大姿态差为 `6.19443716062783e-05 deg`，说明 V7 Simulink 数值上复现了 V6 ode45 模型。V7 是当前最终版本。

## 3. 为什么最终放弃 NAVION 固定翼 Plant

最终放弃 NAVION 固定翼 Plant 的原因不是它不能运行，也不是柔性项无法接入，而是它不适合作为严格的柔性扑翼动力学验证平台。

主要原因如下。

第一，NAVION Plant 的物理对象是固定翼飞机，状态变量为固定翼刚体运动状态，不包含扑翼角、扑翼频率、翼面柔性变形、翼-流耦合、左右翼非定常气动差异等扑翼核心变量。因此即使柔性翼修正项接入了导数通道，也只能解释为“等效扰动”，而不是扑翼动力学结构的一部分。

第二，V3 暴露出零尺度等价性失败。当理论上柔性修正关闭时，模型仍与 baseline 相差约 `194.674012 deg`。这类问题说明模型接线、缓存函数或残余扰动会污染结果，使非零增益结论不可解释。

第三，V4 修复零尺度等价性后，非零小增益扫描几乎不可观测，最大 RMSE 相对变化仅 `4.25173875595223e-08`。这说明在严格零尺度等价和保守小增益映射下，NAVION 接口对柔性扑翼项并不敏感。

第四，V5 通过大范围通道敏感性扫描找到了可观测组合，但这个组合本质上依赖人为选择注入通道和增益放大：

```text
combined channel, dx_gain_multiplier = 10000
```

它适合说明“某些 NAVION 导数通道对等效扰动敏感”，但不适合说明“柔性扑翼动力学本身成立或改善飞行性能”。

因此，转向专用扑翼姿态动力学 Plant 是必要的。专用 Plant 将柔性翼项直接放入姿态转动方程，使惯性、柔性气动力和尾流补偿可以按机制分组进入力矩通道，结果更符合论文/专利中“机理建模与仿真验证”的表述边界。

## 4. V7 模型结构、动力学方程与控制结构

### 4.1 状态变量

V7 采用六状态简化姿态模型：

```text
x = [phi, theta, psi, p, q, r]^T
```

其中：

- `phi` 为 roll；
- `theta` 为 pitch；
- `psi` 为 yaw；
- `p, q, r` 分别为 roll、pitch、yaw 角速度。

在小角度简化下，姿态角导数直接取角速度：

```text
phi_dot   = p
theta_dot = q
psi_dot   = r
```

### 4.2 转动动力学方程

V7 的核心转动方程为：

```text
p_dot = (Mx_control + Mx_flex - Dx*p) / Jx
q_dot = (My_control + My_flex - Dy*q) / Jy
r_dot = (Mz_control + Mz_flex - Dz*r) / Jz
```

合并写为：

```text
J * omega_dot = M_control + M_flexible - D_rate * omega
```

其中：

```text
omega = [p, q, r]^T
J = diag(Jx, Jy, Jz)
D_rate = diag(Dx, Dy, Dz)
M_flexible = [Mx_flex, My_flex, Mz_flex]^T
```

V7 使用的惯量和阻尼参数继承自 V6：

```text
Jx = 0.045 kg*m^2
Jy = 0.055 kg*m^2
Jz = 0.070 kg*m^2
Dx = 0.08
Dy = 0.10
Dz = 0.12
```

这些参数为简化机理仿真参数，不应解释为某一真实样机的精确辨识结果。

### 4.3 柔性翼修正项

V7 通过 `flapping_wing_flexible_forces_v7.m` 调用 V6 的柔性翼项生成函数，输出：

```text
[F_inertia,
 M_inertia_pitch,
 F_flex_lift,
 F_flex_thrust,
 F_flex_drag,
 F_wake,
 Mx_flex,
 My_flex,
 Mz_flex]
```

扑翼角近似为：

```text
phi_wing = A0 * sin(2*pi*f_flap*t)
```

扑翼角加速度为：

```text
phi_wing_ddot = -A0 * (2*pi*f_flap)^2 * sin(2*pi*f_flap*t)
```

惯性项：

```text
M_raw_single = J_phi_wing * phi_wing_ddot
F_raw_single = M_raw_single / r_cp
F_inertia = 2 * scale_inertia * F_raw_single
M_inertia_pitch = 2 * scale_inertia * M_raw_single
```

柔性气动力修正项采用“平均修正 + 周期波动”形式：

```text
F_flex_lift   = scale_flex * (dL_avg_total + dL_max_total * sin(phase))
F_flex_thrust = scale_flex * (0.2*dT_max_total + dT_max_total * sin(phase))
F_flex_drag   = scale_flex * (0.2*dD_max_total + dD_max_total * sin(phase))
```

尾流补偿项为：

```text
F_wake = scale_wake * (
    Kwc1_total*sin(phi_wing)
  + Kwc2_total*cos(phi_wing)
  + Kwc3_total*sin(2*phi_wing)
  + Kwc4_total*cos(2*phi_wing)
)
```

力到力矩的简化映射为：

```text
Mx_flex = l_roll  * 0.1 * F_flex_lift
My_flex = M_inertia_pitch + l_pitch * (F_flex_lift + 0.2*F_flex_drag)
Mz_flex = l_yaw * (F_flex_thrust + F_wake)
```

并加入柔性力矩限幅：

```text
|Mx_flex|, |My_flex|, |Mz_flex| <= M_flex_limit = 0.5 N*m
```

V7 最终报告显示四组工况 `moment_saturation_ratio = 0`，说明当前参数下柔性力矩没有触发饱和限幅。

### 4.4 控制结构

V7 未修改原始 L1 控制器。V7 专用 Plant 使用独立的简化 PD 姿态控制器：

```text
Mx = Kp_roll  * (roll_ref  - roll)  - Kd_roll  * p
My = Kp_pitch * (pitch_ref - pitch) - Kd_pitch * q
Mz = Kp_yaw   * (yaw_ref   - yaw)   - Kd_yaw   * r
```

控制力矩限幅为：

```text
|M_control| <= 1.5 N*m
```

控制目标为零姿态：

```text
roll_ref = 0
pitch_ref = 0
yaw_ref = 0
```

初始姿态为：

```text
roll0 = 5 deg
pitch0 = 8 deg
yaw0 = 5 deg
```

因此四组工况的最大姿态角均为 `8 deg`，主要来自初始 pitch 偏差。

## 5. 四组仿真结果分析

V7 四组仿真结果均由 `sim('flapping_wing_attitude_plant_v7')` 生成。主要指标如下：

| 工况 | 最大姿态角 deg | 最终姿态 deg | 姿态 RMSE deg | RMSE 相对变化 | IAE | 角速度能量 | 柔性力矩 RMS | 力矩饱和比例 |
|---|---:|---|---|---:|---:|---:|---|---:|
| rigid_baseline | 8.000000 | [-0.000000, -0.000002, -0.000034] | [1.175101, 1.956481, 1.374266] | 0 | 8.500617 | 0.038651 | [0, 0, 0] | 0 |
| inertia_only | 8.000000 | [-0.000000, 0.089476, -0.000034] | [1.175101, 1.613034, 1.374266] | 0.09045811 | 8.658981 | 0.192002 | [0, 0.299320, 0] | 0 |
| inertia_flex | 8.000000 | [-0.030908, -0.268171, 1.508761] | [1.168414, 1.600583, 2.163724] | 0.10134681 | 15.947296 | 0.220303 | [0.002514, 0.324109, 0.058404] | 0 |
| inertia_flex_wake | 8.000000 | [-0.030908, -0.268171, 2.331329] | [1.168414, 1.600583, 2.798557] | 0.28717811 | 19.699891 | 0.220844 | [0.002514, 0.324109, 0.074912] | 0 |

### 5.1 rigid_baseline

`rigid_baseline` 关闭惯性修正、柔性气动力修正和尾流修正。该工况用于定义简化刚性翼姿态恢复响应。最终姿态接近零，说明 PD 姿态控制器可以在无柔性扰动下稳定该六状态 Plant。

该工况的角速度能量为 `0.038651`，是四组中最低值。柔性力矩 RMS 为零，符合模型定义。

### 5.2 inertia_only

`inertia_only` 仅启用扑翼惯性修正。主要影响体现在 pitch 通道：最终 pitch 为 `0.089476 deg`，pitch RMSE 从 baseline 的 `1.956481 deg` 降为 `1.613034 deg`。同时角速度能量增至 `0.192002`，说明惯性修正引入了额外周期性力矩，使系统需要更强动态调节。

该工况相对 baseline 的 RMSE 相对变化为 `0.09045811`，处于可观测范围。它说明扑翼惯性项即使不加入柔性气动力，也会改变姿态动态过程。

### 5.3 inertia_flex

`inertia_flex` 同时启用惯性项和柔性气动力项，但不启用尾流补偿。该工况开始出现明显 yaw 偏移，最终 yaw 为 `1.508761 deg`，yaw RMSE 为 `2.163724 deg`，高于 baseline 的 `1.374266 deg`。

柔性气动力通过 `F_flex_lift`、`F_flex_thrust`、`F_flex_drag` 进入 roll、pitch、yaw 力矩映射。结果说明在当前简化参数下，柔性气动力对 yaw 通道的影响比对 roll 通道更明显。IAE 增至 `15.947296`，说明整体姿态误差积分增加。

该结果不应解释为“柔性翼改善了控制性能”。更稳妥的解释是：柔性气动力修正项引入了可观测姿态扰动，并改变了不同姿态通道的误差分布。

### 5.4 inertia_flex_wake

`inertia_flex_wake` 启用惯性、柔性气动力和尾流补偿三类修正。最终 yaw 增至 `2.331329 deg`，yaw RMSE 增至 `2.798557 deg`，RMSE 相对变化为 `0.28717811`，是四组中最大。

相比 `inertia_flex`，该工况主要增加 yaw 通道偏移。这与 V7 力矩映射一致：

```text
Mz_flex = l_yaw * (F_flex_thrust + F_wake)
```

因此尾流项主要通过 `Mz_flex` 影响 yaw。该结果支持“尾流补偿项在简化模型中可改变偏航响应”的机制性判断，但不支持直接宣称尾流补偿提升真实飞行性能。

## 6. 参数敏感性分析结果

V7 进行了两类参数敏感性分析：

1. 同步改变 `scale_inertia` 与 `scale_flex`；
2. 固定惯性/柔性尺度，改变 `scale_wake`。

### 6.1 惯性/柔性尺度扫描

| 工况 | scale_inertia | scale_flex | scale_wake | max_att deg | rmse_norm | final_yaw deg | stable |
|---|---:|---:|---:|---:|---:|---:|---:|
| flex_scale_0p025 | 0.025 | 0.025 | 0.05 | 8.000000 | 3.037872 | 1.576932 | 1 |
| flex_scale_0p05 | 0.05 | 0.05 | 0.05 | 8.000000 | 3.429137 | 2.331329 | 1 |
| flex_scale_0p075 | 0.075 | 0.075 | 0.05 | 8.000000 | 3.943863 | 3.085726 | 1 |
| flex_scale_0p1 | 0.10 | 0.10 | 0.05 | 8.000000 | 4.534331 | 3.840124 | 1 |

结果显示，随着惯性/柔性尺度增大，`rmse_norm` 和最终 yaw 偏移均单调增大。所有测试点最大姿态角仍为 `8 deg`，没有出现发散。这说明当前 Plant 对柔性项尺度具有连续响应，且在测试范围内保持稳定。

### 6.2 尾流尺度扫描

| 工况 | scale_inertia | scale_flex | scale_wake | max_att deg | rmse_norm | final_yaw deg | stable |
|---|---:|---:|---:|---:|---:|---:|---:|
| wake_scale_0 | 0.05 | 0.05 | 0 | 8.000000 | 2.934069 | 1.508761 | 1 |
| wake_scale_0p025 | 0.05 | 0.05 | 0.025 | 8.000000 | 3.167667 | 1.920045 | 1 |
| wake_scale_0p05 | 0.05 | 0.05 | 0.05 | 8.000000 | 3.429137 | 2.331329 | 1 |
| wake_scale_0p075 | 0.05 | 0.05 | 0.075 | 8.000000 | 3.712595 | 2.742613 | 1 |
| wake_scale_0p1 | 0.05 | 0.05 | 0.10 | 8.000000 | 4.013385 | 3.153897 | 1 |

尾流尺度增大时，最终 yaw 偏移从 `1.508761 deg` 增至 `3.153897 deg`，说明尾流补偿项在当前映射下主要影响偏航力矩。该趋势与 `Mz_flex = l_yaw * (F_flex_thrust + F_wake)` 的结构一致。

敏感性分析的总体结论是：V7 对柔性项和尾流项具有可解释的参数响应，且在测试区间内稳定。但由于参数来自文献近似和简化映射，敏感性结果应作为机理趋势而非定量设计依据。

## 7. 当前模型的适用范围

V7 适用于以下场景：

1. 作为柔性扑翼修正项的简化姿态动力学验证平台；
2. 比较刚性基线、惯性修正、柔性气动力修正、尾流补偿项对姿态响应的相对影响；
3. 验证柔性项是否能通过力矩通道引起稳定、可观测、可区分的姿态变化；
4. 为论文或专利提供“基于文献近似参数的简化机理仿真”证据；
5. 作为后续高保真气动弹性模型、专用扑翼飞行器 Simulink Plant 或实机辨识模型的前置验证。

## 8. 当前模型的局限性

V7 的主要局限性如下。

第一，模型为六状态姿态模型，不包含平动动力学、空间轨迹、速度变化、攻角变化和高度变化，因此不能描述完整飞行任务。

第二，柔性翼修正项来自文献近似参数和简化正弦表达，没有求解真实 FSI、非定常涡结构、翼面变形模态或流场分布。

第三，左右翼差动、翼根驱动机构、舵面/扑翼耦合、执行器动态和传感器噪声均未精细建模。

第四，控制器是简化 PD 姿态控制器，不是原论文中的 L1 自适应控制器。V7 没有修改 L1 控制器，也不应被表述为 L1 控制律性能提升验证。

第五，当前参数未经过实机辨识或风洞标定。惯量、阻尼、力臂和柔性力尺度是用于机制验证的合理近似，不是某个具体扑翼飞行器的高精度参数。

第六，最大姿态角等于 `8 deg` 主要由初始 pitch 偏差决定，不应把“最大姿态角未增大”解释为柔性项天然提高稳定性。更准确的说法是：在当前控制器、初始条件和参数范围下，柔性修正没有导致发散。

## 9. 可用于论文或专利的创新点表述

以下表述可用于论文或专利初稿，但建议保持“简化机理仿真”的边界。

| 创新点 | 可用表述 | 证据来源 | 表述边界 |
|---|---|---|---|
| 固定翼模型到扑翼专用模型的验证路线 | 提出一种由固定翼等效扰动验证过渡到专用扑翼姿态动力学 Plant 的分阶段建模流程 | V1-V7 迭代记录 | 不能声称 NAVION 直接验证了扑翼真实动力学 |
| 零尺度等价性诊断 | 引入 `global_correction_scale = 0` 的零尺度等价性检查，避免残余扰动或旧接线污染柔性翼效应判断 | V3/V4 对比，V4 zero-equivalence PASS | 是仿真可信性诊断，不是控制性能提升 |
| 柔性翼修正项分解 | 将柔性翼影响分解为惯性项、柔性气动力项和尾流补偿项，并分别进行 ablation 对比 | V7 四组工况 | 参数为文献近似和简化映射 |
| 平均修正 + 周期波动建模 | 将柔性气动力表示为平均修正与扑翼周期波动叠加，避免零均值项无法体现平均气动变化 | `flapping_wing_flexible_forces_v6/v7` | 不是完整非定常气动力模型 |
| Simulink 动态 Plant 固化 | 将 ode45 六状态模型固化为连续状态 Simulink S-function Plant，并验证与 ode45 一致 | V6/V7 equivalence PASS，最大姿态差 `6.19e-05 deg` | 数值一致性不等于高保真物理真实性 |
| 工况分组与敏感性分析 | 通过 `rigid_baseline`、`inertia_only`、`inertia_flex`、`inertia_flex_wake` 及尺度扫描评估不同柔性机制对姿态响应的影响 | V7 report 与 sensitivity report | 结果是趋势性和机制性，不是实测性能预测 |

可直接使用的谨慎表述如下：

```text
本文基于文献近似柔性翼气动力参数，建立了一个六状态简化扑翼姿态动力学模型，将扑翼惯性修正、柔性气动力修正和尾流补偿项以等效力矩形式引入姿态转动方程。通过刚性基线、惯性项、柔性气动力项和尾流补偿项四组工况对比，验证了各类柔性修正项对姿态响应具有可观测且可区分的影响。进一步将 ode45 脚本模型固化为 Simulink 连续状态 Plant，并通过最大姿态误差小于 0.05 deg 的一致性检验证明 Simulink 模型能够复现实验脚本结果。该模型定位为简化机理仿真平台，可为柔性扑翼控制建模和后续高保真建模提供前置验证。
```

不建议使用的夸大表述包括：

```text
该模型真实复现了扑翼飞行器飞行过程。
柔性翼修正显著提升了真实飞行控制性能。
V7 验证了 L1 自适应控制器在柔性扑翼飞行器上的真实性能优势。
仿真结果可直接作为样机设计定量依据。
```

## 10. 图表与可复现实验索引

V7 主要模型与脚本：

```text
flapping_wing_attitude_plant_v7.slx
init_flapping_wing_v7_params.m
flapping_wing_flexible_forces_v7.m
flapping_wing_attitude_dynamics_v7.m
flapping_wing_attitude_sfun_v7.m
build_flapping_wing_attitude_plant_v7.m
run_flapping_wing_simulink_comparison_v7.m
compare_v6_ode_v7_simulink.m
sensitivity_sweep_flapping_wing_v7.m
calculate_flapping_wing_metrics_v7.m
plot_flapping_wing_results_v7.m
```

V7 主要结果文件：

```text
simulation_results_v7/v6_v7_equivalence_report.txt
simulation_results_v7/flapping_wing_v7_report.txt
simulation_results_v7/sensitivity_report_v7.txt
simulation_results_v7/v7_results_for_gpt_review.md
simulation_results_v7/result_v7_rigid_baseline.mat
simulation_results_v7/result_v7_inertia_only.mat
simulation_results_v7/result_v7_inertia_flex.mat
simulation_results_v7/result_v7_inertia_flex_wake.mat
simulation_results_v7/metrics_v7.mat
```

V7 主要图件：

```text
simulation_results_v7/attitude_comparison_v7.png
simulation_results_v7/flexible_moment_terms_v7.png
simulation_results_v7/ablation_rmse_bar_v7.png
simulation_results_v7/final_attitude_bar_v7.png
simulation_results_v7/sensitivity_rmse_v7.png
simulation_results_v7/sensitivity_final_yaw_v7.png
```

## 11. 最终建议

后续论文或专利写作建议采用如下定位：

1. 将 V1-V5 写成“固定翼模型中柔性项接入与等效扰动验证的探索过程”，重点强调零尺度等价性诊断和 NAVION 局限；
2. 将 V6-V7 写成“专用简化扑翼姿态动力学 Plant 的建立与 Simulink 固化验证”；
3. 将四组工况结果表述为柔性机制对姿态响应的可观测影响，不写成真实性能提升；
4. 将敏感性分析作为参数趋势验证，不作为样机定量设计依据；
5. 若要进一步提升学术可信度，下一阶段应引入专用扑翼气动模型、翼面柔性模态、左右翼差动输入、执行器模型，并用风洞或实验数据标定关键参数。

