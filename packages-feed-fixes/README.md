# packages feed 本地改动 —— 备份与使用说明

## 这是什么

OpenWrt 官方的 **packages feed**（`feeds/packages`）里，我对 **golang** 和 **rust** 做了大量本地修改：

- `golang`：新增 `golang1.26`、`golang-bootstrap`、`golang-version.mk`，改造了一整套 `.mk` 构建脚本
- `rust`：修改 Makefile / patch / `.mk`，并加了一条修复（configure 前自动删除残留的 `bootstrap.toml`，否则反复编译会报 `Existing 'bootstrap.toml' detected. Exiting`）

**问题**：`feeds.conf` 把 packages feed 锁定在固定提交（`^c7d1a8c1...`），每次执行
`./scripts/feeds update -a` 都会强制 checkout 回官方版本，**把上面这些改动全部冲掉**。

**解决**：把全部改动用 git 导出成一个补丁 `my-packages-fixes.patch`，更新 feeds 后再自动打回。
> 注意：`helloworld` feed 是自己的 git 仓库，**不受影响**，无需处理。这里只针对官方 packages feed。

## 文件清单

| 文件 | 作用 |
|------|------|
| `my-packages-fixes.patch` | 全部本地改动的补丁（22 个文件，golang 全套 + rust） |
| `save-fixes.sh` | **改完之后**用它把改动刷新进补丁 |
| `feeds-rebuild.sh` | **更新 feeds 时**用它，自动：update → 打回补丁 → install |

## 怎么用（部署到编译机）

编译机当前路径假设为 `/home/kali/openwrt`。三个文件本来就放在那里；这个目录是它们在
`helloworld` 仓库里的**备份**。换机器/重装系统后，把三个文件拷回 openwrt 根目录即可：

```sh
cp my-packages-fixes.patch save-fixes.sh feeds-rebuild.sh /home/kali/openwrt/
cd /home/kali/openwrt
chmod +x save-fixes.sh feeds-rebuild.sh
```

### 场景 1：更新 feeds（替代 `feeds update -a && feeds install -a`）

```sh
cd /home/kali/openwrt
sh feeds-rebuild.sh
```

脚本会依次：更新所有 feeds → 把 `my-packages-fixes.patch` 打回 packages feed → 重新 install。
打回失败（官方 feed 变动导致冲突）时会自动尝试三方合并并提示需要手动处理的地方。

### 场景 2：改了 go 版本 / rust 版本 / 修了新的编译问题

```sh
cd /home/kali/openwrt
# 1. 直接编辑 feeds/packages/lang/golang/... 或 lang/rust/... 里的文件
# 2. 把最新改动刷新进补丁：
sh save-fixes.sh
# 3. 把更新后的 my-packages-fixes.patch 拷回本仓库 packages-feed-fixes/ 并提交，保持备份最新
```

### 编译

```sh
cd /home/kali/openwrt
make -j$(nproc) world
# 出错时单独定位：make -j1 V=s world
```

## 重要提示

- 只要 `feeds.conf` 里 packages 的锁定提交（`^c7d1a8c1...`）不变，补丁就能**干净打回**。
- 如果哪天把锁定提交升级到更新的版本，官方文件变了可能造成补丁部分冲突 —— `feeds-rebuild.sh`
  会提示，按提示手动改完后再 `./scripts/feeds install -a` 即可，然后记得 `save-fixes.sh` 刷新补丁。
- 每次更新完补丁，记得把 `my-packages-fixes.patch` 同步回这个目录并 `git commit`，否则备份会过时。
