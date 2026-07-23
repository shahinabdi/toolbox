from functools import singledispatch
from dataclasses import is_dataclass, asdict
from datetime import date, datetime
from enum import Enum
from uuid import UUID
from typing import Any

@singledispatch
def serialize_value(value: Any) -> Any:
    """Convert an application value into a JSON-compatible value."""
    if is_dataclass(value) and not isinstance(value, type):
        return serialize_value(asdict(value))
    return value

@serialize_value.register
def _(value: None) -> None:
    return None

@serialize_value.register
def _(value: UUID) -> str:
    return str(value)

@serialize_value.register
def _(value: date) -> str:  # covers datetime too (subclass)
    return value.isoformat()

@serialize_value.register
def _(value: Enum) -> Any:
    return serialize_value(value.value)

@serialize_value.register
def _(value: dict) -> dict:
    return {str(k): serialize_value(v) for k, v in value.items()}

@serialize_value.register(list)
@serialize_value.register(tuple)
@serialize_value.register(set)
@serialize_value.register(frozenset)
def _(value) -> list:
    return [serialize_value(item) for item in value]
