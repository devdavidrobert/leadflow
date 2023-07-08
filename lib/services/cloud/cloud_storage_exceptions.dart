class CloudStorageException implements Exception {
  const CloudStorageException();
}

//Create
class CouldNotCreateLeadException extends CloudStorageException {}

//Read
class CouldNotGetAllLeadsException extends CloudStorageException {}

//Update
class CouldNotUpdateLeadException extends CloudStorageException {}

//Delete
class CouldNotDeleteLeadException extends CloudStorageException {}
