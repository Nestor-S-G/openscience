from enum import Enum

class HttpStatus(Enum):
    OK_200 = 200
    CREATED_201 = 201
    NO_CONTENT_SUCCESS_204 = 204
    BAD_REQUEST_400 = 400
    FORBIDDEN_403 = 403
    MISSING_404 = 404