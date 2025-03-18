db = db.getSiblingDB('webue_db');

db.createUser({
  user: 'user',
  pwd: 'password',
  roles: [
    {
      role: 'readWrite',
      db: 'webue_db'
    }
  ]
});
