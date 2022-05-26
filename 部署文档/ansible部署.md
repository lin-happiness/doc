## ansible、ansible-tower部署

### 一、ansible安装
```shell
# 安装ansible
yum install -y ansible

# 生成密钥对 
ssh-keygen -t rsa

# 将公钥放到目标主机（此处为了测试放到了本机）
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys 
#通过ssh登陆一下
ssh root@127.0.0.1


#增加配置
vi /etc/ansible/hosts 
[testhost]
127.0.0.1

# ansible远程执行命令
ansible testhost -m command -a 'w'

```

### 二、ansible-tower安装
```shell
wget https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-3.7.0-4.tar.gz
tar -zxvf ansible-tower-setup-3.7.0-4.tar.gz 
cd ansible-tower-setup-3.7.0-4

# 修改配置

vi inventory

#修改内容


[tower]
localhost ansible_connection=local

[database]

[all:vars]
admin_password='abc.123'

pg_host='127.0.0.1'
pg_port='5432'

pg_database='awx'
pg_username='awx'
pg_password='abc.123'
pg_sslmode='prefer'  # set to 'verify-full' for client-side enforced SSL



# 创建日志目录，要不然安装的时候报错 
mkdir -p /var/log/tower 

# 运行安装（时间很长，等待一会）
./setup.sh


#安装结束
PLAY [Install Tower isolated node(s)] ****************************************************************************************************************************
skipping: no hosts matched

PLAY RECAP *******************************************************************************************************************************************************
localhost                  : ok=157  changed=88   unreachable=0    failed=0    skipped=68   rescued=0    ignored=2   

The setup process completed successfully.
Setup log saved to /var/log/tower/setup-2022-05-26-10:32:09.log.

#访问
http://IP/
账号密码：admin/abc.123  (密码为inventory文件配置：admin_password='abc.123')


```
### ansible-tower破解
```shell
# 进入许可验证目录
cd /var/lib/awx/venv/awx/lib/python3.6/site-packages/tower_license
# 查看文件
ls

__init__.pyc __pycache__


#安装pip（如果安装时downloading失败，需要多次尝试）
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
python get-pip.py
#查看pip版本
pip -V

pip 20.3.4 from /usr/lib/python2.7/site-packages/pip (python 2.7)
# 安装反编译模块
pip install uncompyle6



#反汇编init.pyc
uncompyle6 __init__.pyc >__init__.py
# 查看文件
ls

get-pip.py  __init__.py  __init__.pyc  __pycache__
# 修改文件
vi __init__.py

#添加代码（89行）
    def _check_cloudforms_subscription(self):
        return True    #添加这一行（注意代码格式）
        if os.path.exists('/var/lib/awx/i18n.db'):
            return True
        else:
            if os.path.isdir('/opt/rh/cfme-appliance'):
                if os.path.isdir('/opt/rh/cfme-gemset'):
                    pass
            try:
                has_rpms = subprocess.call(['rpm', '--quiet', '-q', 'cfme', 'cfme-appliance', 'cfme-gemset'])
                if has_rpms == 0:
                    return True
            except OSError:
                pass

            return False
....

#修改"license_date=253370764800L" 为 "license_date=253370764800"（84行）
    def _generate_cloudforms_subscription(self):
        self._attrs.update(dict(company_name='Red Hat CloudForms License', instance_count=MAX_INSTANCES,
          license_date=253370764800,  #修改
          license_key='xxxx',
          license_type='enterprise',
          subscription_name='Red Hat CloudForms License'))
...
#注释掉两行（175，176行）
    except requests.exceptions.ConnectionError as error:
        raise error
    #except OSError as error:
        #raise OSError('Unable to open certificate bundle {}. Check that Ansible Tower is running on Red Hat Enterprise Linux.'.format(verify)) from error

#------------------------------------------------------------------

#修改完重新编译一下

python -m py_compile __init__.py
python -O -m py_compile __init__.py

# 查看文件
get-pip.py  __init__.py  __init__.pyc  __init__.pyc.bak  __init__.pyo  __pycache__

#重启服务
systemctl restart ansible-tower

# 登陆系统查看许可情况


```



