import { MstToolPage } from './app.po';

describe('mst-tool App', () => {
  let page: MstToolPage;

  beforeEach(() => {
    page = new MstToolPage();
  });

  it('should display welcome message', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('Welcome to app!');
  });
});
