import os
import re
import argparse
from pathlib import Path

def to_snake_case(name: str) -> str:
    """
    将各种命名风格转换为 snake_case。
    处理：camelCase, PascalCase, kebab-case, space separated, 已有下划线混乱等。
    """
    # 1. 将空格、连字符、点号（不包括扩展名的点）替换为下划线
    #    注意：这个函数只接收不含扩展名的纯文件名主体，因此点号直接替换是安全的
    s = re.sub(r'[\s\-\.]+', '_', name)
    
    # 2. 在大小写边界插入下划线（处理驼峰）
    #    (?<=[a-z])(?=[A-Z]) : 小写后面紧跟大写 -> 下划线
    #    (?<=[A-Z])(?=[A-Z][a-z]) : 大写序列后面跟一个大写小写开头（处理类似 XMLHttpRequest 中的 XML_Http）
    s = re.sub(r'(?<=[a-z])(?=[A-Z])', '_', s)
    s = re.sub(r'(?<=[A-Z])(?=[A-Z][a-z])', '_', s)
    
    # 3. 将内部已有的下划线统一化（去重、去首尾）
    s = re.sub(r'_+', '_', s)
    s = s.strip('_')
    
    # 4. 全部转为小写
    return s.lower()

def safe_rename(file_path: Path, dry_run: bool = True) -> None:
    """安全重命名：只修改文件名主体，保留扩展名，冲突时自动添加后缀"""
    if not file_path.is_file():
        return
    
    stem = file_path.stem          # 文件名主体（不含扩展名）
    extension = file_path.suffix   # 包括点号的扩展名，如 .txt
    
    new_stem = to_snake_case(stem)
    new_name = new_stem + extension
    
    new_path = file_path.parent / new_name
    
    # 处理文件名冲突：若目标文件已存在，追加数字后缀
    if new_path.exists():
        counter = 1
        while True:
            candidate = file_path.parent / f"{new_stem}_{counter}{extension}"
            if not candidate.exists():
                new_path = candidate
                break
            counter += 1
    
    if dry_run:
        print(f"[DRY RUN] 将重命名: {file_path.name} -> {new_path.name}")
    else:
        try:
            file_path.rename(new_path)
            print(f"[重命名] {file_path.name} -> {new_path.name}")
        except Exception as e:
            print(f"[错误] 无法重命名 {file_path.name}: {e}")

def main():
    parser = argparse.ArgumentParser(description="将目录下所有文件名转换为 snake_case")
    parser.add_argument("directory", nargs="?", default=".", help="目标目录（默认当前目录）")
    parser.add_argument("--recursive", "-r", action="store_true", help="递归处理子目录")
    parser.add_argument("--dry-run", "-n", action="store_true", help="预览模式，不实际重命名")
    parser.add_argument("--extensions", "-e", nargs="+", help="只处理指定扩展名的文件，如 .mp3 .txt（不指定则处理所有）")
    args = parser.parse_args()
    
    root = Path(args.directory).resolve()
    if not root.is_dir():
        print(f"错误：目录 {root} 不存在")
        return
    
    # 收集要处理的文件
    if args.recursive:
        files = root.rglob("*")
    else:
        files = root.glob("*")
    
    for file_path in files:
        if not file_path.is_file():
            continue
        
        # 扩展名过滤
        if args.extensions:
            if file_path.suffix.lower() not in [ext.lower() for ext in args.extensions]:
                continue
        
        safe_rename(file_path, dry_run=args.dry_run)

if __name__ == "__main__":
    main()