import request from '@/utils/request'

// Migration Task
export function getMigrationTaskList(params?: any) { return request.get('/cpq/migration/task/list', { params }) }
export function getMigrationTaskById(id: number) { return request.get(`/cpq/migration/task/${id}`) }
export function addMigrationTask(data: any) { return request.post('/cpq/migration/task', data) }
export function updateMigrationTask(data: any) { return request.put('/cpq/migration/task', data) }
export function deleteMigrationTask(ids: string) { return request.delete(`/cpq/migration/task/${ids}`) }

// Migration Mapping
export function getMigrationMappingList(params?: any) { return request.get('/cpq/migration/mapping/list', { params }) }
export function addMigrationMapping(data: any) { return request.post('/cpq/migration/mapping', data) }
export function updateMigrationMapping(data: any) { return request.put('/cpq/migration/mapping', data) }
export function deleteMigrationMapping(ids: string) { return request.delete(`/cpq/migration/mapping/${ids}`) }

// Migration Log
export function getMigrationLogList(params?: any) { return request.get('/cpq/migration/log/list', { params }) }
export function deleteMigrationLog(ids: string) { return request.delete(`/cpq/migration/log/${ids}`) }

// Migration workflow
export function createWorkflow(data: any) { return request.post('/cpq/migration/workflow/create', data) }
