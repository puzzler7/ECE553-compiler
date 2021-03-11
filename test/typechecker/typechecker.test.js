const fs = require('fs');
const { spawnSync, spawn } = require('child_process');
const { test, it } = require('@jest/globals');

const cmMakeMsg = '[New bindings added.]';

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

    test.each(cases)(
        'parses %s correctly',
        (testFile) => {
            const parseResults = spawnSync(`sml`, { input: getScript(testFile) })
            expect(parseResults.error).toBeFalsy();
            expect(parseResults.stderr.toString()).toBe('');

            const stdout = parseResults.stdout.toString()
            expect(stdout.includes(cmMakeMsg)).toBeTruthy();
            expect(stdout.slice(stdout.indexOf(cmMakeMsg) + cmMakeMsg.length)).toMatchSnapshot();
            //expect(errorMessagePattern.test(parseResults.stdout.toString())).toBeFalsy();
        }
    );
})