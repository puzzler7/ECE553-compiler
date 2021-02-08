const fs = require('fs');
const { spawnSync } = require('child_process');

const getRelativePathOfTests = (dir) => {
    return fs.readdirSync(dir)
             .filter(fileName => /^.*\.tig$/.exec(fileName))
             .map(fileName => dir + fileName);

}

describe('Maverick\'s cool custom tests', () => {
    const cases = getRelativePathOfTests('../../test/');

    test.each(cases)(
        'parses %s correctly',
        (testFile) => {
            const parseResults = spawnSync('./lexerParse', [testFile]);
            expect(parseResults.error).toBeFalsy();
            expect(parseResults.stderr.length).toBe(0);
            expect(parseResults.stdout.toString()).toMatchSnapshot();
        }
    );
})

describe('The textbook tests', () => {
    const cases = getRelativePathOfTests('../../../bookfiles/testcases/');

    test.each(cases)(
        'parses %s correctly',
        (testFile) => {
            const parseResults = spawnSync('./lexerParse', [testFile])
            expect(parseResults.error).toBeFalsy();
            expect(parseResults.stderr.length).toBe(0);
            expect(parseResults.stdout.toString()).toMatchSnapshot();
        }
    );
})