from jinja2 import Template, Environment, FileSystemLoader
from lib.utils import key_to_lua, value_to_lua

# 正确配置环境
env = Environment(
    loader=FileSystemLoader("lib"),  # 指定模板目录
)