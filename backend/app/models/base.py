# Đây là class cơ sở dùng để các model ORM khác kế thừa
# Nó định nghĩa Base cần thiết để SQLAlchemy nhận diện các bảng
from sqlalchemy.orm import declarative_base

Base = declarative_base()
