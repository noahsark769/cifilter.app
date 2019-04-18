import React from 'react';
import styled from 'styled-components';
import TitleMark from './TitleMark';
import { IoLogoGithub, IoLogoTwitter, IoIosAppstore } from "react-icons/io";

const StyledNav = styled.nav`
    width: 100%;
    display: flex;
    flex-direction: horizontal;
`;

const TitleMarkContainer = styled.div`
    flex: 2;
`;

const Other = styled.div`
    flex: 10;

    display: flex;
    flex-direction: horizontal;
    justify-content: flex-end;
    align-items: center;
`;

const NavLink = styled.a`
    color: #F5BD5D;
    cursor: pointer;
    font-weight: bold;

    &:hover {
        text-decoration: underline;
    }
`;

const Nav = (props) => {
    return (
        <StyledNav className="padding--md">
            <TitleMarkContainer>
                <TitleMark />
            </TitleMarkContainer>
            <Other>
                {/*}
                // TODO: Re-enable these links once we have gatsby pages for them
                <NavLink className="margin-right--md">SUPPORT</NavLink>
            */}
                <NavLink className="margin-right--md" href="https://itunes.apple.com/us/app/cifilter-io/id1457458557?mt=8"><IoIosAppstore size="24" /></NavLink>
                <NavLink className="margin-right--md" href="https://twitter.com/cifilterio"><IoLogoTwitter size="24" /></NavLink>
                <NavLink className="margin-right--md" href="https://github.com/noahsark769/cifilter.io"><IoLogoGithub size="24" /></NavLink>
            </Other>
        </StyledNav>
    )
};
export default Nav;