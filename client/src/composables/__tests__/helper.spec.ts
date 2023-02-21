import { describe, it, expect } from 'vitest'
import {getNodeFromTree} from "../helper";


describe('getNodeFromTree', () => {
  it('should return the node for given path in the tree', () => {
    const path = '/src/models/test.sql'
    const tree = {
      path: '/src',
      children: [
        {
          path: '/src/models',
          children: [
            {
              path: '/src/models/yyy.sql'
            },
            {
              path: '/src/models/test.sql'
            },
            {
              path: '/src/models/xxx.sql'
            }
          ]
        },
        {
          path: '/src/models',
          children: [
            {
              path: '/src/models/yyy.sql'
            }
          ]
        }
      ]
    }
    const result = getNodeFromTree(tree, path)
    expect(result.path).toBe(path)
  }),

  it('should return undefined when no tree provided', () => {
    const path = ''
    const tree = undefined
    const result = getNodeFromTree(tree, path)
    expect(result).toBeUndefined()
  }),

  it('should return undefined when no path is provided', () => {
    const path = undefined
    const tree = {}
    const result = getNodeFromTree(tree, path)
    expect(result).toBeUndefined()
  })
})
