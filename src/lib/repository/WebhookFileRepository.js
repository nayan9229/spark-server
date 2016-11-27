import type { Webhook } from '../../types';

import FileManager from './FileManager';
import uuid from '../uuid';

class WebhookFileRepository {
  _fileManager: FileManager;

  constructor(path: string) {
    this._fileManager = new FileManager(path);
  }

  create(model: Webhook): Webhook {
    const modelToSave = {
      ...model,
      created_at: new Date(),
      // TODO: Add another repository for fetching users. This should be
      // injected on every request so we can easily get the current user
      created_by: null, // user id
      id: uuid(),
    };

    this._fileManager.createFile(modelToSave.id + '.json', modelToSave);
    return modelToSave;
  }

  delete(id: string): void {
    this._fileManager.deleteFile(id + '.json');
  }

  getAll(): Array<Webhook> {
    return this._fileManager.getAllData();
  }

  getById(id: string): Webhook {
    return this._fileManager.getFile(id + '.json');
  }
}

export default WebhookFileRepository;
