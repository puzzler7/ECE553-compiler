const fs = require('fs');
const { spawnSync, spawn } = require('child_process');
const { test, it } = require('@jest/globals');

const cmMakeMsg = '[New bindings added.]';
const errorMessagePattern = /tig:[0-9]+.[0-9]+:/;
const positiveTests = [
    'merge.tig',
    'queens.tig',
    'test1.tig',
    'test2.tig',
    'test3.tig',
    'test4.tig',
    'test5.tig',
    'test6.tig',
    'test7.tig',
    'test8.tig',
    'test12.tig',
    'test27.tig',
    'test30.tig',
    'test37.tig',
    'test41.tig',
    'test42.tig',
    'test44.tig',
    'test46.tig',
    'test47.tig',
    'test48.tig'
]

const getRelativePathOfTests = (dir) => {
    return fs.readdirSync(dir)
             .filter(fileName => /^.*\.tig$/.exec(fileName))
             .map(fileName => dir + fileName);

}

const getScript = (filePath) => {
    return `CM.make "src/typechecker/sources.cm"; Main.typecheckOnly("${filePath}");`
}

describe('The textbook tests', () => {
    const cases = getRelativePathOfTests('test/testcases/');
    const positiveCases = cases.filter(path => 
        positiveTests.find(test => path.includes(test))
    )
    const negativeCases = cases.filter(path => !positiveCases.includes(path))

    test.each(positiveCases)(
        'finds no type errors in %s',
        (testFile) => {
            const parseResults = spawnSync(`sml`, { input: getScript(testFile) })
            expect(parseResults.error).toBeFalsy();
            expect(parseResults.stderr.toString()).toBe('');

            const stdout = parseResults.stdout.toString()
            expect(stdout.includes(cmMakeMsg)).toBeTruthy();
            expect(stdout.slice(stdout.indexOf(cmMakeMsg) + cmMakeMsg.length)).toMatchSnapshot();
            expect(errorMessagePattern.test(parseResults.stdout.toString())).toBeFalsy();
        }
    );

    test.each(negativeCases)(
        'correctly finds type errors in %s',
        (testFile) => {
            const parseResults = spawnSync(`sml`, { input: getScript(testFile) })
            expect(parseResults.error).toBeFalsy();
            expect(parseResults.stderr.toString()).toBe('');

            const stdout = parseResults.stdout.toString()
            expect(stdout.includes(cmMakeMsg)).toBeTruthy();
            expect(stdout.slice(stdout.indexOf(cmMakeMsg) + cmMakeMsg.length)).toMatchSnapshot();
            expect(errorMessagePattern.test(parseResults.stdout.toString())).toBeTruthy();
        }
    );
})